use strict;
use warnings;

use Test::More;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(
    data_file
    fval
    hm_to_minute
    interpolate_brightness
    load_data
    minute_to_hm
    now_minute
    save_data
    update_point
);

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

subtest 'Time & value helpers' => sub {
    # minute_to_hm
    is(minute_to_hm(0),    "00:00", "HM: Midnight renders as 00:00");
    is(minute_to_hm(605),  "10:05", "HM: Mid-day minute renders correctly");
    is(minute_to_hm(1439), "23:59", "HM: Last minute of the day");
    is(minute_to_hm(1440), "00:00", "HM: Wraps at a full day");

    # hm_to_minute
    is(hm_to_minute("10:05"), 605,  "Minute: Parses HH:MM");
    is(hm_to_minute("930"),   570,  "Minute: Parses HHMM");
    ok(!defined hm_to_minute("24:00"), "Minute: Rejects hour out of range");
    ok(!defined hm_to_minute("10:75"), "Minute: Rejects minute out of range");
    ok(!defined hm_to_minute("junk"),  "Minute: Rejects garbage");

    # fval
    is(fval("12.5"), 12.5, "fval: Numeric string coerced");
    is(fval(-3),     -3,   "fval: Negative number kept");
    is(fval("junk"), 0,    "fval: Garbage becomes 0");
    is(fval(undef),  0,    "fval: Undefined becomes 0");

    # now_minute
    my $now = now_minute();
    ok($now >= 0 && $now <= 1439, "now: Within a single day (got $now)");
};

subtest 'Persistence round-trip' => sub {
    require File::Temp;
    my ($fh, $path) = File::Temp::tempfile(UNLINK => 1);
    close $fh;

    # Missing / blank / malformed files all degrade to an empty dataset
    is_deeply(load_data("$path.missing"), {}, "Load: Missing file yields empty data");
    is_deeply(load_data($path),           {}, "Load: Blank file yields empty data");

    open my $bad, '>', $path or die $!;
    print $bad "{ this is not json";
    close $bad;
    is_deeply(load_data($path), {}, "Load: Malformed JSON yields empty data instead of dying");

    # Round-trip real data
    my $data = {};
    update_point($data, 90,   42.5, 5);
    update_point($data, 1200, 80,   5);
    ok(save_data($path, $data), "Save: Writes the dataset");

    my $reloaded = load_data($path);
    is($reloaded->{90},   "42.50", "Round-trip: First point preserved");
    is($reloaded->{1200}, "80.00", "Round-trip: Second point preserved");

    ok(!eval { save_data('/nonexistent-dir-radiance/x.json', $data); 1 },
        "Save: Dies on unwritable path");
};

subtest 'Shared cache path' => sub {
    {
        local $ENV{RADIANCE_FILE} = '/tmp/custom_radiance.json';
        is(data_file(), '/tmp/custom_radiance.json', "Path: \$RADIANCE_FILE override honoured");
    }
    {
        local $ENV{RADIANCE_FILE};
        require File::Spec;
        is(data_file(),
            File::Spec->catfile($ENV{HOME} // '', '.cache', 'radiance_data.json'),
            "Path: Falls back to the default cache file");
    }
};

done_testing();
