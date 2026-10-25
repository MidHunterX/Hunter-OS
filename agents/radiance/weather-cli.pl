#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(data_file interpolate_brightness load_data now_minute);
use Weather qw(cached_weather delta describe_code env_file weather_factor);

my $WEATHER_REFRESH_MINS = 30;  # Reuse cached conditions until this long

my $weather = cached_weather($WEATHER_REFRESH_MINS * 60);

die "Weather fetch failed and no cached data available\n" unless $weather;

# No coordinates configured: report the disabled state
if ($weather->{disabled}) {
    warn "Weather disabled: RADIANCE_LATITUDE/RADIANCE_LONGITUDE are not set.\n"
       . "Add them to " . env_file() . " to enable the brightness correction.\n";
    printf "Suggested brightness delta: 0%%\n";
    exit 0;
}

my $base   = interpolate_brightness(load_data(data_file()), now_minute());
my $target = $base + delta($base, $weather);
$target = 0   if $target < 0;
$target = 100 if $target > 100;

printf "Weather code: %d (%s)%s\n",
    $weather->{weather_code},
    describe_code($weather->{weather_code}),
    $weather->{stale} ? " (cached)" : "";
printf "Learned now: %.2f%% | Factor: x%.2f\n", $base, weather_factor($weather);
printf "Suggested brightness delta: %+.2f%% -> target %.2f%%\n",
    delta($base, $weather), $target;
