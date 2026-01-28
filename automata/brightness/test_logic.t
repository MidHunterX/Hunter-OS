use strict;
use warnings;

use Test::More;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use logic qw(interpolate_brightness);

# Test Case: Empty Data
is(interpolate_brightness({}, 100), 0, "Interpolate: 0 on empty data");

# Test Case: Exact Match
my $data = { 600 => 50, 1200 => 100 };
is(interpolate_brightness($data, 600), 50, "Interpolate: Exact match found on dataset");

# Test Case: Simple Interpolation (Middle of day)
# At 900 mins (halfway between 600 and 1200), brightness should be 75
is(interpolate_brightness($data, 900), 75, "Interpolate: Linear interpolation logic");

# Test Case: Midnight Wrap-around
# Data: 22:00 (1320m) = 10%, 02:00 (120m) = 50%
# Current: 00:00 (0m)
my $wrap_data = { 1320 => 10, 120 => 50 };
# Total distance = 120 + 120 = 240 mins. 0 is exactly halfway.
# Expected result: 30%
is(interpolate_brightness($wrap_data, 0), 30, "Interpolate: Midnight wrap-around logic");

done_testing();
