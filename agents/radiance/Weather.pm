package Weather;

# Weather-driven brightness delta for radiance.
# Fetches current conditions from Open-Meteo (no API key required), translate
# them into a brightness delta (percentage) and cache the result so consumers
# can reuse it until it ages out instead of hitting the API on every tick.
#
# The coordinates are sensitive and live in a .env file next to this module
# (sourced on load, see env_file()/load_env()). Without them the weather
# module is disabled and reports a delta of 0.

use strict;
use warnings;
use JSON::PP qw(decode_json);
use File::Spec;
use File::Basename qw(dirname);
use Exporter qw(import);

# Reuse the shared JSON reader for the cache file.
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(fval load_data);

our @EXPORT_OK = qw(
    cache_file
    cached_delta
    delta_from
    env_file
    fetch_current
    fetch_delta
    is_fresh
    load_env
    location
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

# Translate WMO weather code + cloud cover into a brightness delta.
# Pure function: no I/O, safe to unit test.
sub delta_from {
    my ($weather_code, $cloud_cover, $intensity) = @_;
    $weather_code //= 0;
    $cloud_cover  //= 0;
    $intensity    //= 1.0;

    my $delta = 0;

    # WMO Weather Codes interpretation
    if ($weather_code == 0 || $weather_code == 1) {
        $delta = 0;           # Clear / mainly clear
    }
    elsif ($weather_code == 2 || $weather_code == 3) {
        $delta = -5;          # Partly cloudy / overcast
    }
    elsif ($weather_code >= 45 && $weather_code <= 48) {
        $delta = -15;         # Fog
    }
    elsif ($weather_code >= 51 && $weather_code <= 67) {
        $delta = -10;         # Drizzle / rain / freezing rain
    }
    elsif ($weather_code >= 71 && $weather_code <= 77) {
        $delta = -5;          # Snow
    }
    elsif ($weather_code >= 80 && $weather_code <= 82) {
        $delta = -12;         # Rain showers
    }
    elsif ($weather_code >= 95) {
        $delta = -20;         # Thunderstorm
    }

    # Extra dimming if very overcast
    if ($cloud_cover > 80 && $delta > -20) {
        $delta -= 5;
    }

    # Apply intensity multiplier
    return int($delta * $intensity);
}

# ============================== FETCHING =================================== #

# Grab the current conditions. Returns a hashref on success, undef on any
# failure (no network, bad JSON, missing fields) so callers can fall back.
sub fetch_current {
    my ($lat, $lon) = location();
    return undef unless defined $lat;   # coordinates missing: disabled

    my $url = "https://api.open-meteo.com/v1/forecast"
            . "?latitude=$lat&longitude=$lon"
            . "&current=temperature_2m,weather_code,cloud_cover";

    # -s silent, -S show errors, -f fail on HTTP errors, --max-time timeout
    my $json = `curl -sSf --max-time 10 "$url" 2>&1`;
    return undef if $? != 0 || !defined $json || $json eq '';

    my $data = eval { decode_json($json) };
    return undef if $@ || ref $data ne 'HASH' || ref $data->{current} ne 'HASH';

    my $current = $data->{current};
    return undef unless defined $current->{weather_code};

    return {
        weather_code => fval($current->{weather_code}),
        cloud_cover  => fval($current->{cloud_cover}),
    };
}

# Fetch conditions and turn them into a cache entry:
# { weather_code, cloud_cover, delta, fetched_at }
sub fetch_delta {
    my $current = fetch_current() or return undef;
    return {
        %$current,
        delta      => delta_from($current->{weather_code}, $current->{cloud_cover}, $INTENSITY),
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
    # Must look like something we wrote; Logic::load_data returns {} otherwise.
    return undef unless exists $cache->{fetched_at} && exists $cache->{delta};
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

# Reuse the cached delta until it ages out, then re-fetch. On fetch failure
# the stale cache is served instead (flagged with stale => 1); if there is no
# cache at all, undef is returned so callers can default to delta 0.
sub cached_delta {
    my ($max_age_secs) = @_;
    $max_age_secs //= $REFRESH_SECS;

    # Without coordinates (no/incomplete .env) the weather module is disabled:
    # report a delta of 0 and never touch the cache or the network.
    if (!location_ok()) {
        return { delta => 0, stale => 0, disabled => 1 };
    }

    my $cache = load_cache();
    if ($cache && is_fresh($cache, $max_age_secs)) {
        $cache->{stale} = 0;
        return $cache;
    }

    my $fresh = fetch_delta();
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

# Source the radiance .env at load time so the coordinates are available.
load_env();

1; # Must return a true value
