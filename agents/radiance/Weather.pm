package Weather;

# Weather-driven brightness correction for radiance.

use strict;
use warnings;
use JSON::PP qw(decode_json);
use File::Spec;
use File::Basename qw(dirname);
use Exporter qw(import);

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(fval load_data);

our @EXPORT_OK = qw(
    adjust_brightness
    cache_file
    cached_weather
    delta
    describe_code
    env_file
    fetch_conditions
    fetch_current
    is_fresh
    load_env
    location
    severity
    weather_factor
);

# ============================== CONFIGURATION ============================== #

our $INTENSITY    = 1.0;        # Delta multiplier (1.0 = normal, 0.5 = subtle, 2.0 = aggressive)
our $REFRESH_SECS = 30 * 60;    # Default reuse window when the caller passes no age limit

# ============================== ENVIRONMENT ================================ #

# Location of the .env file holding the sensitive coordinates. Override with
# $RADIANCE_ENV_FILE (used by tests).
sub env_file {
    return $ENV{RADIANCE_ENV_FILE}
        if defined $ENV{RADIANCE_ENV_FILE} && length $ENV{RADIANCE_ENV_FILE};
    return File::Spec->catfile(dirname(__FILE__), '.env');
}

# Source a dotenv-style file (KEY=value, '#' comments, optional 'export ').
# Values already present in the environment are never overwritten, so a real
# export always beats the file.
sub load_env {
    my ($path) = @_;
    $path //= env_file();
    return 0 unless defined $path && -e $path;

    open my $fh, '<', $path or return 0;
    my $set = 0;
    while (my $line = <$fh>) {
        $line =~ s/\r?\n\z//;
        next if $line =~ /^\s*(?:#.*)?$/;                          # blank / comment
        next unless $line =~ /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/;
        my ($key, $value) = ($1, $2);
        $value =~ s/\A(['"])(.*)\1\z/$2/;                          # strip matching quotes
        next if defined $ENV{$key} && length $ENV{$key};           # env wins over file
        $ENV{$key} = $value;
        $set++;
    }
    close $fh;
    return $set;
}

# Coordinates as (latitude, longitude), validated. An empty list means they
# are not configured, which disables the whole weather delta.
sub location {
    my ($lat, $lon) = @ENV{qw(RADIANCE_LATITUDE RADIANCE_LONGITUDE)};
    return () unless defined $lat && length $lat && defined $lon && length $lon;
    return () unless $lat =~ /\A-?\d+(?:\.\d+)?\z/ && $lon =~ /\A-?\d+(?:\.\d+)?\z/;
    return () unless $lat >= -90 && $lat <= 90 && $lon >= -180 && $lon <= 180;
    return ($lat + 0, $lon + 0);
}

sub location_ok { my @loc = location(); return @loc == 2; }

# ============================== SHARED PATHS =============================== #

# Cache location, overridable via $RADIANCE_WEATHER_FILE (mirrors $RADIANCE_FILE).
sub cache_file {
    return $ENV{RADIANCE_WEATHER_FILE}
        if defined $ENV{RADIANCE_WEATHER_FILE} && length $ENV{RADIANCE_WEATHER_FILE};
    my $home = $ENV{HOME} // '';
    return File::Spec->catfile($home, '.cache', 'radiance_weather.json');
}

# ============================== DELTA LOGIC ================================ #

sub severity {
    my ($weather_code) = @_;
    $weather_code = fval($weather_code);

    my $s = 0;

    # WMO Weather Codes interpretation
    if    ($weather_code == 0 || $weather_code == 1) { $s = 0.00; }  # Clear / mainly clear
    elsif ($weather_code == 2 || $weather_code == 3) { $s = 0.05; }  # Partly cloudy / overcast
    elsif ($weather_code >= 45 && $weather_code <= 48) { $s = 0.15; }# Fog
    elsif ($weather_code >= 51 && $weather_code <= 67) { $s = 0.10; }# Drizzle / rain / freezing rain
    elsif ($weather_code >= 71 && $weather_code <= 77) { $s = 0.05; }# Snow
    elsif ($weather_code >= 80 && $weather_code <= 82) { $s = 0.12; }# Rain showers
    elsif ($weather_code >= 95) { $s = 0.20; }                      # Thunderstorm

    return $s;
}

# Human-readable meaning of a WMO weather code, for display only
sub describe_code {
    my ($weather_code) = @_;
    return 'unknown' unless defined $weather_code && $weather_code =~ /\A\d+\z/;

    my %text = (
        0  => 'Clear sky',
        1  => 'Mainly clear',
        2  => 'Partly cloudy',
        3  => 'Overcast',
        45 => 'Fog',
        48 => 'Depositing rime fog',
        51 => 'Light drizzle',
        53 => 'Moderate drizzle',
        55 => 'Dense drizzle',
        56 => 'Light freezing drizzle',
        57 => 'Dense freezing drizzle',
        61 => 'Slight rain',
        63 => 'Moderate rain',
        65 => 'Heavy rain',
        66 => 'Light freezing rain',
        67 => 'Heavy freezing rain',
        71 => 'Slight snowfall',
        73 => 'Moderate snowfall',
        75 => 'Heavy snowfall',
        77 => 'Snow grains',
        80 => 'Slight rain showers',
        81 => 'Moderate rain showers',
        82 => 'Violent rain showers',
        85 => 'Slight snow showers',
        86 => 'Heavy snow showers',
        95 => 'Thunderstorm',
        96 => 'Thunderstorm with slight hail',
        99 => 'Thunderstorm with heavy hail',
    );
    return $text{$weather_code} // 'unknown code';
}

# Multiplier for the learned brightness: 1.0 = untouched, 0.85 = 15% off.
sub weather_factor {
    my ($weather, $intensity) = @_;
    $intensity //= $INTENSITY;
    return 1 unless $weather && !$weather->{disabled};

    my $s = severity($weather->{weather_code}) * $intensity;
    $s = 0   if $s < 0;
    $s = 0.9 if $s > 0.9;   # Never dim by more than 90%, whatever the intensity
    return 1 - $s;
}

# Scale the learned brightness for the current minute by the weather factor.
sub adjust_brightness {
    my ($learned, $weather, $intensity) = @_;
    $learned = fval($learned);
    my $adjusted = $learned * weather_factor($weather, $intensity);
    return $adjusted < 0 ? 0 : $adjusted;
}

# Signed delta in percentage points for a given learned brightness, for
# logging/CLI display. Negative = dimmer than the learned curve.
sub delta {
    my ($learned, $weather, $intensity) = @_;
    return adjust_brightness($learned, $weather, $intensity) - fval($learned);
}

# ============================== FETCHING =================================== #

# Grab the current conditions. Returns a hashref on success, undef on any
# failure (no network, bad JSON, missing fields) so callers can fall back.
sub fetch_current {
    my ($lat, $lon) = location();
    return undef unless defined $lat;   # coordinates missing: disabled

    my $url = "https://api.open-meteo.com/v1/forecast"
            . "?latitude=$lat&longitude=$lon"
            . "&current=temperature_2m,weather_code";

    # -s silent, -S show errors, -f fail on HTTP errors, --max-time timeout
    my $json = `curl -sSf --max-time 10 "$url" 2>&1`;
    return undef if $? != 0 || !defined $json || $json eq '';

    my $data = eval { decode_json($json) };
    return undef if $@ || ref $data ne 'HASH' || ref $data->{current} ne 'HASH';

    my $current = $data->{current};
    return undef unless defined $current->{weather_code};

    return {
        weather_code => fval($current->{weather_code}),
    };
}

# Fetch conditions and turn them into a cache entry:
# { weather_code, fetched_at }
sub fetch_conditions {
    my $current = fetch_current() or return undef;
    return {
        %$current,
        fetched_at => time(),
    };
}

# ============================== CACHE ====================================== #

# A cache entry is usable until it is older than $max_age_secs.
sub is_fresh {
    my ($cache, $max_age_secs) = @_;
    return 0 unless $cache && defined $cache->{fetched_at};
    return (time() - fval($cache->{fetched_at})) < $max_age_secs;
}

sub load_cache {
    my $cache = load_data(cache_file());
    return undef unless exists $cache->{fetched_at} && exists $cache->{weather_code};
    return $cache;
}

sub save_cache {
    my ($cache) = @_;
    open my $fh, '>', cache_file() or return 0;
    print {$fh} JSON::PP->new->canonical->encode($cache);
    close $fh;
    return 1;
}

# ============================== MAIN ENTRY ================================= #

sub cached_weather {
    my ($max_age_secs) = @_;
    $max_age_secs //= $REFRESH_SECS;

    # Without coordinates (no/incomplete .env) the weather module is disabled:
    # report no conditions and never touch the cache or the network.
    if (!location_ok()) {
        return { stale => 0, disabled => 1 };
    }

    my $cache = load_cache();
    if ($cache && is_fresh($cache, $max_age_secs)) {
        $cache->{stale} = 0;
        return $cache;
    }

    my $fresh = fetch_conditions();
    if ($fresh) {
        $fresh->{stale} = 0;
        save_cache($fresh);
        return $fresh;
    }

    if ($cache) {
        $cache->{stale} = 1;   # Keep running on old data rather than going blind
        return $cache;
    }
    return undef;
}

load_env();

1; # Must return a true value
