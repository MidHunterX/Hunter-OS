use strict;
use warnings;

use Test::More;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(interpolate_brightness update_point);

subtest 'Interpolation Logic' => sub {
    # Test Case: Empty Data
    is(interpolate_brightness({}, 100), 0, "Interpolate: 0 on empty data");

    # Test Case: Exact Match
    my $data = { 600 => 50, 1200 => 100 };
    is(interpolate_brightness($data, 600), 50, "Interpolate: Exact match found on dataset");

    # Test Case: Simple Interpolation (Middle of day)
    # At 900 mins (halfway between 600 and 1200), brightness should be 75
    is(interpolate_brightness($data, 900), 75, "Interpolate: Linear interpolation logic");

    # Test Case: Midnight Wrap-around (At Midnight)
    # Data: 22:00 (1320m) = 10, 02:00 (120m) = 50
    # Current: 00:00 (0m)
    my $wrap_data = { 1320 => 10, 120 => 50 };
    # Total distance = (1440 - 1320) + 120 = 240 mins.
    # Current distance from 1320 is 120 mins (halfway).
    is(interpolate_brightness($wrap_data, 0), 30, "Interpolate: Wrap-around at exactly 00:00");

    # Test Case: Midnight Wrap-around (Late night)
    # Current: 23:00 (1380m)
    # Dist from 1320 = 60. Ratio = 60/240 = 0.25.
    # Val = 10 + (50 - 10) * 0.25 = 20
    is(interpolate_brightness($wrap_data, 1380), 20, "Interpolate: Wrap-around while still in late PM");
};


subtest 'Update Point & Window Logic' => sub {
    # Test Case: Basic update
    my $data = { 100 => 10 };
    update_point($data, 100, 25.5, 5);
    is($data->{100}, "25.50", "Update: Replaced existing exact key");

    # Test Case: Proximity detection (Window removal)
    # Adding a point at 505 should remove 500 if window is 10
    my $win_data = { 500 => 10, 700 => 80 };
    update_point($win_data, 505, 15, 10);

    ok(!exists $win_data->{500}, "Window: Removed point within padding distance");
    is($win_data->{505}, "15.00", "Window: New point added");
    ok(exists $win_data->{700}, "Window: Distant point untouched");

    # Test Case: Midnight Wrap-around Window
    # Existing point at 23:58 (1438). Setting at 00:02 (2).
    # Distance is 4 minutes.
    my $mid_data = { 1438 => 5 };
    update_point($mid_data, 2, 10, 5);

    ok(!exists $mid_data->{1438}, "Window: Midnight wrap-around removal works");
    is($mid_data->{2}, "10.00", "Window: New point set at start of day");

    # Test Case: Multiple removal
    my $multi_data = { 10 => 1, 12 => 1, 14 => 1, 18 => 1 };
    update_point($multi_data, 12, 5, 5); # Should clear 10, 12, and 14
    is(scalar keys %$multi_data, 2, "Window: Cleared multiple clustered points");
    ok(exists $multi_data->{18}, "Window: Kept point outside cluster");
};

done_testing();
