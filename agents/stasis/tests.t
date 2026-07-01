# vim: set filetype=perl :
use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin";
require "$FindBin::Bin/logic.pl";

# time_to_minutes tests
is(time_to_minutes("00:00"), 0,    "time_to_minutes: Midnight boundary");
is(time_to_minutes("12:00"), 720,  "time_to_minutes: Normal midday");
is(time_to_minutes("23:59"), 1439, "time_to_minutes: End-of-day boundary");
is(time_to_minutes("08:05"), 485,  "time_to_minutes: Leading zeros handled");

# minutes_to_time tests
is(minutes_to_time(0), "00:00",    "minutes_to_time: Midnight conversion");
is(minutes_to_time(720), "12:00",  "minutes_to_time: Midday conversion");
is(minutes_to_time(1439), "23:59", "minutes_to_time: End of day conversion");
is(minutes_to_time(1440), "00:00", "minutes_to_time: Exactly 24 hours (overflow)");
is(minutes_to_time(1500), "01:00", "minutes_to_time: > 24 hours (positive wrap)");
is(minutes_to_time(-15), "23:45",  "minutes_to_time: Negative wrap-around handling");

# calculate_median_time tests
is(calculate_median_time([], "09:00"), "09:00",
   "calculate_median_time: Falls back gracefully if array is empty");
is(calculate_median_time(["08:00"], "09:00"), "08:00",
   "calculate_median_time: Works with single data point");
is(calculate_median_time(["08:00", "10:00", "09:00"], "12:00"), "09:00",
   "calculate_median_time: Sorts and finds middle value of odd count");
is(calculate_median_time(["08:00", "10:00"], "12:00"), "09:00",
   "calculate_median_time: Averages middle values of even count");
is(calculate_median_time(["08:00", "08:15"], "12:00"), "08:07",
   "calculate_median_time: Truncates fractional minute division smoothly");

# in_time_range tests (Standard daytime range: 09:00 - 17:00 -> 540 to 1020 minutes)
ok(in_time_range(600, 540, 1020),  "in_time_range: Inside standard daytime range");
ok(in_time_range(540, 540, 1020),  "in_time_range: Start boundary check (inclusive)");
ok(!in_time_range(1020, 540, 1020), "in_time_range: End boundary check (exclusive)");
ok(!in_time_range(300, 540, 1020),  "in_time_range: Outside standard daytime range");

# in_time_range tests (Overnight range: 22:00 - 06:00 -> 1320 to 360 minutes)
ok(in_time_range(120, 1320, 360),  "in_time_range: Morning portion of overnight range");
ok(in_time_range(1380, 1320, 360), "in_time_range: Evening portion of overnight range");
ok(!in_time_range(600, 1320, 360), "in_time_range: Day portion outside overnight range");

# get_action_for_time tests
is(get_action_for_time(600, "09:00", "17:00"), "systemctl suspend",
   "get_action_for_time: Suspend during defined work window");
is(get_action_for_time(1140, "09:00", "17:00"), "systemctl poweroff",
   "get_action_for_time: Poweroff outside defined work window");

done_testing();
