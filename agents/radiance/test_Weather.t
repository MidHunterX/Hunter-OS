use strict;
use warnings;

use Test::More;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Weather qw(cache_file cached_delta delta_from env_file is_fresh load_env location);

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

subtest 'Delta from WMO weather codes' => sub {
    is(delta_from(0, 50),  0,   "Clear sky: no change");
    is(delta_from(1, 50),  0,   "Mainly clear: no change");
    is(delta_from(2, 50),  -5,  "Partly cloudy: small dim");
    is(delta_from(3, 50),  -5,  "Overcast: small dim");
    is(delta_from(3, 90),  -10, "Overcast + >80% cloud: extra -5");
    is(delta_from(45, 50), -15, "Fog: heavy dim");
    is(delta_from(55, 50), -10, "Rain: moderate dim");
    is(delta_from(71, 50), -5,  "Snow: small dim");
    is(delta_from(81, 50), -12, "Rain showers: moderate-heavy dim");
    is(delta_from(95, 50), -20, "Thunderstorm: strongest dim");
    is(delta_from(95, 95), -20, "Thunderstorm never dims past -20");
    is(delta_from(40, 50), 0,   "Unmapped code: no change");

    # Intensity multiplier
    is(delta_from(2, 50, 0.5), -2, "Intensity 0.5 softens the delta");
    is(delta_from(2, 50, 2.0), -10, "Intensity 2.0 doubles the delta");

    # Tolerates missing fields
    is(delta_from(undef, undef), 0, "Missing code/cloud tolerated");
};

subtest 'Cache freshness' => sub {
    ok(is_fresh({ fetched_at => time() }, 60),        "Fresh: young entry accepted");
    ok(!is_fresh({ fetched_at => time() - 120 }, 60), "Stale: old entry rejected");
    ok(!is_fresh(undef, 60),                          "Fresh: no entry rejected");
    ok(!is_fresh({}, 60),                             "Fresh: entry without timestamp rejected");
};

subtest 'Reuse cached delta until refresh is due' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, cloud_cover => 40, delta => -5, fetched_at => time() });

    my $fetched = 0;
    local *Weather::fetch_current = sub { $fetched++; return undef; };

    my $w = cached_delta(600);
    is($w->{delta}, -5,  "Delta served from cache");
    is($w->{stale}, 0,   "Fresh cache not flagged stale");
    is($fetched,     0,  "No API call while cache is fresh");

    # A cached delta of exactly 0 is still a valid result
    write_cache($path, { weather_code => 0, cloud_cover => 10, delta => 0, fetched_at => time() });
    $w = cached_delta(600);
    is($w->{delta}, 0, "Zero delta cache is honoured");
    is($fetched,    0, "Still no API call for a zero-delta cache");
};

subtest 'Refresh once the cache ages out' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, cloud_cover => 40, delta => -5, fetched_at => time() - 7200 });

    my $fetched = 0;
    local *Weather::fetch_current = sub {
        $fetched++;
        return { weather_code => 95, cloud_cover => 100 };
    };

    my $w = cached_delta(600);
    is($fetched,     1,   "Stale cache triggers a refetch");
    is($w->{delta}, -20,  "Fresh delta returned");
    is($w->{stale},  0,   "Fresh fetch not flagged stale");
    is(read_cache($path)->{delta}, -20, "Cache file updated with fresh result");
};

subtest 'Fetch failure falls back to the cache' => sub {
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;
    local %ENV = %ENV;
    $ENV{RADIANCE_LATITUDE} = '8.4';
    $ENV{RADIANCE_LONGITUDE} = '77.1';
    local $ENV{RADIANCE_WEATHER_FILE} = $path;

    write_cache($path, { weather_code => 3, cloud_cover => 40, delta => -5, fetched_at => time() - 7200 });

    local *Weather::fetch_current = sub { return undef; };

    my $w = cached_delta(600);
    is($w->{delta}, -5, "Stale cache served when fetch fails");
    is($w->{stale}, 1,  "Fallback data flagged stale");
    is(read_cache($path)->{delta}, -5, "Cache file left untouched by failed fetch");

    # No cache at all + failing fetch: caller gets undef and defaults to 0
    unlink $path;
    ok(!defined cached_delta(600), "Undef returned when nothing is cached and fetch fails");
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
    write_cache($path, { weather_code => 3, cloud_cover => 40, delta => -5, fetched_at => time() });

    local *Weather::fetch_current = sub { die "must not touch the network while disabled" };

    my $w = cached_delta(600);
    is($w->{delta},    0,   "Disabled: delta is 0");
    ok($w->{disabled},      "Disabled: flagged so callers can report it");
    is($w->{stale},    0,   "Disabled: not flagged stale");
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
