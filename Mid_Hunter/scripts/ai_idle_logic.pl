#!/usr/bin/env perl
use strict;
use warnings;

# CONFIGURATION
# ================================

# Time format: HH:MM (24-hour)
my $WORK_START  = "06:00";
my $WORK_END    = "16:00";

my $SLEEP_START = "20:00";
my $SLEEP_END   = "03:00";

# ================================

# HH:MM -> minutes
sub to_minutes {
	my ($time) = @_;
	my ($hour, $minute) = split /:/, $time;
	return $hour * 60 + $minute;
}

# if now is between start and end
sub in_range {
	my ($now, $start, $end) = @_;
	# Normal range (same day)
	if ($start <= $end) {
		return ($now >= $start && $now < $end);
	}
	# Overnight range (e.g. 23:00 → 06:00)
	else {
		return ($now >= $start || $now < $end);
	}
}

# TIME CALCULATION

my ($sec, $min, $hour) = localtime;
my $NOW_MINUTES = $hour * 60 + $min;
my $WORK_START_M  = to_minutes($WORK_START);
my $WORK_END_M    = to_minutes($WORK_END);
my $SLEEP_START_M = to_minutes($SLEEP_START);
my $SLEEP_END_M   = to_minutes($SLEEP_END);

# DECISION LOGIC

if (in_range($NOW_MINUTES, $WORK_START_M, $WORK_END_M)) {
	print "Work hours (suspend)\n";
	system("systemctl suspend");
}
elsif (in_range($NOW_MINUTES, $SLEEP_START_M, $SLEEP_END_M)) {
	print "Sleep hours (poweroff)\n";
	system("systemctl poweroff");
}
else {
	print "Neutral hours (DPMS off)\n";
	system("hyprctl dispatch dpms off");
}
