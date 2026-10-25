use strict;
use warnings;

use Test::More;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Weather qw(
    adjust_brightness
    cache_file
    cached_weather
    delta
    describe_code
    env_file
    is_fresh
    load_env
    location
    severity
    weather_factor
);

require File::Temp;
require JSON::PP;

# ---------- helpers ----------

sub write_cache {
    my ($path, $cache) = @_;
    open my $fh, '>', $path or die $!;
    print $fh JSON::PP::encode_json($cache);
    close $fh;
}

sub read_cache {
    my ($path) = @_;
    open my $fh, '<', $path or die $!;
    local $/;
    return JSON::PP::decode_json(<$fh>);
}

# Floating-point comparisons
sub approx {
    my ($got, $exp, $name) = @_;
    cmp_ok(abs($got - $exp), '<', 1e-9, $name);
}

subtest 'Severity mapping (fraction of brightness removed)' => sub {
    approx(severity(0),  0.00, "Clear sky: no dimming");
    approx(severity(1),  0.00, "Mainly clear: no dimming");
    approx(severity(2),  0.05, "Partly cloudy: 5%");
    approx(severity(3),  0.05, "Overcast: 5%");
    approx(severity(45), 0.15, "Fog: 15%");
    approx(severity(55), 0.10, "Rain: 10%");
    approx(severity(71), 0.05, "Snow: 5%");
    approx(severity(81), 0.12, "Rain showers: 12%");
    approx(severity(95), 0.20, "Thunderstorm: 20%");
    approx(severity(40), 0.00, "Unmapped code: no dimming");
    approx(severity(undef), 0, "Missing code tolerated");

    # A leftover cloud_cover field (old cache entries) must not influence it
    approx(severity(3, 95), 0.05, "cloud_cover is ignored");
};

subtest 'Weather code descriptions' => sub {
    is(describe_code(0),  'Clear sky',              "Code 0 described");
    is(describe_code(3),  'Overcast',               "Code 3 described");
    is(describe_code(45), 'Fog',                    "Fog code described");
    is(describe_code(81), 'Moderate rain showers',  "Shower code described");
    is(describe_code(99), 'Thunderstorm with heavy hail', "Top thunderstorm code described");
    is(describe_code(40), 'unknown code',           "Unmapped code says so instead of guessing");
    is(describe_code(undef), 'unknown',             "Missing code tolerated");
    is(describe_code('abc'), 'unknown',             "Garbage code tolerated");
};

subtest 'Correction scales with the learned brightness' => sub {
    my $overcast = { weather_code => 3 };   # severity 0.05

    # Bright learned value on a cloudy day: lowered a lot
    approx(adjust_brightness(95, $overcast), 90.25, "Bright daytime comes down by 5%");
    approx(delta(95, $overcast), -4.75, "Delta is worth -4.75 points at base 95");

    # Same weather, but the learned curve is already dim: only nudged down
    approx(adjust_brightness(12, $overcast), 11.4, "Dim evening only nudges down");
    approx(delta(12, $overcast), -0.6, "Delta is worth just -0.6 points at base 12");
    ok(adjust_brightness(12, $overcast) > 0, "Dim value is never cut off entirely");

    # Clear weather: untouched at any level
    my $clear = { weather_code => 0 };
    approx(adjust_brightness(95, $clear), 95, "Clear day, bright: untouched");
    approx(adjust_brightness(12, $clear), 12, "Clear day, dim: untouched");
    approx(delta(50, $clear), 0, "Clear day: zero delta");

    # Extreme weather scales the same way
    my $storm = { weather_code => 95 };   # severity 0.20
    approx(adjust_brightness(100, $storm), 80, "Storm scales a peak value to 80%");
    approx(adjust_brightness(10, $storm),  8,  "Storm scales a dim value to 8");

    # Intensity softens/hardens the scaling
    approx(weather_factor($overcast, 0.5), 0.975, "Intensity 0.5 halves the correction");
    approx(adjust_brightness(100, $overcast, 0.5), 97.5, "Intensity 0.5 applied to base");

    # Safety rails
    approx(weather_factor({ weather_code => 95 }, 10), 0.1,
        "Never dims by more than 90% even at absurd intensity");
    is(weather_factor(undef, 1), 1, "No weather data: factor 1");
    is(weather_factor({ disabled => 1 }, 1), 1, "Disabled: factor 1");
    approx(adjust_brightness(50, { disabled => 1 }), 50, "Disabled: learned value untouched");
    approx(adjust_brightness(50, undef), 50, "No weather data: learned value untouched");
    is(adjust_brightness(-5, $overcast), 0, "Never goes negative");
};

subtest 'Cache freshness' => sub {
    ok(is_fresh({ fetched_at => time() }, 60),        "Fresh: young entry accepted");
    ok(!is_fresh({ fetched_at => time() - 120 }, 60), "Stale: old entry rejected");
    ok(!is_fresh(undef, 60),                          "Fresh: no entry rejected");
    ok(!is_fresh({}, 60),                             "Fresh: entry without timestamp rejected");
};

subtest 'Reuse cached conditions until refresh is due' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, fetched_at => time() });

    my $fetched = 0;
    local *Weather::fetch_current = sub { $fetched++; return undef; };

    my $w = cached_weather(600);
    is($w->{weather_code}, 3, "Conditions served from cache");
    is($w->{stale}, 0,       "Fresh cache not flagged stale");
    is($fetched,     0,      "No API call while cache is fresh");

    # A clear-sky cache (severity 0) is still a valid result
    write_cache($path, { weather_code => 0, fetched_at => time() });
    $w = cached_weather(600);
    is($w->{weather_code}, 0, "Clear-sky cache is honoured");
    is($fetched,           0, "Still no API call for a clear-sky cache");
};

subtest 'Refresh once the cache ages out' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, fetched_at => time() - 7200 });

    my $fetched = 0;
    local *Weather::fetch_current = sub {
        $fetched++;
        return { weather_code => 95 };
    };

    my $w = cached_weather(600);
    is($fetched,     1,   "Stale cache triggers a refetch");
    is($w->{weather_code}, 95, "Fresh conditions returned");
    is($w->{stale},  0,   "Fresh fetch not flagged stale");
    is(read_cache($path)->{weather_code}, 95, "Cache file updated with fresh result");
};

subtest 'Fetch failure falls back to the cache' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, fetched_at => time() - 7200 });

    local *Weather::fetch_current = sub { return undef; };

    my $w = cached_weather(600);
    is($w->{weather_code}, 3, "Stale cache served when fetch fails");
    is($w->{stale}, 1,        "Fallback data flagged stale");
    is(read_cache($path)->{weather_code}, 3, "Cache file left untouched by failed fetch");

    # No cache at all + failing fetch: caller gets undef and applies no change
    unlink $path;
    ok(!defined cached_weather(600), "Undef returned when nothing is cached and fetch fails");
};

subtest 'Coordinates come from the environment' => sub {
    local %ENV = %ENV;

    $ENV{RADIANCE_LATITUDE}  = '8.3985';
    $ENV{RADIANCE_LONGITUDE} = '77.0859';
    is_deeply([location()], [8.3985, 77.0859], "Location: read from environment");

    $ENV{RADIANCE_LATITUDE}  = '-33.86';
    $ENV{RADIANCE_LONGITUDE} = '151.2';
    is_deeply([location()], [-33.86, 151.2], "Location: southern hemisphere accepted");

    delete $ENV{RADIANCE_LATITUDE};
    is_deeply([location()], [], "Location: missing latitude disables");

    $ENV{RADIANCE_LATITUDE} = 'abc';
    is_deeply([location()], [], "Location: non-numeric value rejected");

    $ENV{RADIANCE_LATITUDE} = '91';
    is_deeply([location()], [], "Location: out-of-range latitude rejected");

    $ENV{RADIANCE_LATITUDE}  = '8.4';
    $ENV{RADIANCE_LONGITUDE} = 'abc';
    is_deeply([location()], [], "Location: bad longitude rejected");
};

subtest 'Weather disabled without coordinates' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    local $ENV{RADIANCE_WEATHER_FILE} = $path;
    delete @ENV{qw(RADIANCE_LATITUDE RADIANCE_LONGITUDE)};

    # Even a perfectly fresh cache is ignored while disabled
    write_cache($path, { weather_code => 3, fetched_at => time() });

    local *Weather::fetch_current = sub { die "must not touch the network while disabled" };

    my $w = cached_weather(600);
    ok($w->{disabled},       "Disabled: flagged so callers can report it");
    is($w->{stale}, 0,       "Disabled: not flagged stale");
    is(delta(50, $w), 0,     "Disabled: delta is 0 at any brightness");
    approx(adjust_brightness(50, $w), 50, "Disabled: learned value passed through");
};

subtest '.env sourcing' => sub {
    local %ENV = %ENV;
    delete @ENV{qw(RADIANCE_LATITUDE RADIANCE_LONGITUDE)};

    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    print $fh "# radiance test env\n"
            . "\n"
            . "RADIANCE_LATITUDE=8.3985\n"
            . "export RADIANCE_LONGITUDE=\"77.0859\"\n";
    close $fh;

    is(load_env($path), 2, "Env: two variables sourced from file");
    is($ENV{RADIANCE_LATITUDE},  '8.3985',  "Env: plain assignment parsed");
    is($ENV{RADIANCE_LONGITUDE}, '77.0859', "Env: export prefix and quotes handled");

    # A real environment export always beats the file
    $ENV{RADIANCE_LATITUDE} = '1.5';
    is(load_env($path), 0, "Env: nothing set when every variable already exists");
    is($ENV{RADIANCE_LATITUDE}, '1.5', "Env: environment value kept");

    is(load_env("$path.missing"), 0, "Env: missing file is a no-op");
};

subtest 'Shared cache path' => sub {
    {
        local $ENV{RADIANCE_WEATHER_FILE} = '/tmp/custom_weather.json';
        is(cache_file(), '/tmp/custom_weather.json', "Path: \$RADIANCE_WEATHER_FILE override honoured");
    }
    {
        local $ENV{RADIANCE_WEATHER_FILE};
        require File::Spec;
        is(cache_file(),
            File::Spec->catfile($ENV{HOME} // '', '.cache', 'radiance_weather.json'),
            "Path: Falls back to the default weather cache file");
    }
    {
        local $ENV{RADIANCE_ENV_FILE} = '/tmp/custom.env';
        is(env_file(), '/tmp/custom.env', "Env file: \$RADIANCE_ENV_FILE override honoured");
    }
    {
        local $ENV{RADIANCE_ENV_FILE};
        is(env_file(), File::Spec->catfile($FindBin::Bin, '.env'),
            "Env file: defaults to .env inside the radiance directory");
    }
};

done_testing();
