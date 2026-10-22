#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Weather qw(cached_delta env_file);

# Thin CLI over Weather.pm. The actual fetch/delta/cache logic lives in the
# module so worker.pl can reuse it; this just prints the current numbers.

my $WEATHER_REFRESH_MINS = 30;  # Reuse the cached delta until this long has passed

my $weather = cached_delta($WEATHER_REFRESH_MINS * 60);

die "Weather fetch failed and no cached data available\n" unless $weather;

# No coordinates configured: report the disabled state instead of real numbers
if ($weather->{disabled}) {
    warn "Weather disabled: RADIANCE_LATITUDE/RADIANCE_LONGITUDE are not set.\n"
       . "Add them to " . env_file() . " to enable the brightness delta.\n";
    printf "Suggested brightness delta: %d%%\n", $weather->{delta};
    exit 0;
}

printf "Weather code: %d | Cloud cover: %d%%%s\n",
    $weather->{weather_code}, $weather->{cloud_cover},
    $weather->{stale} ? " (cached)" : "";
printf "Suggested brightness delta: %d%%\n", $weather->{delta};
