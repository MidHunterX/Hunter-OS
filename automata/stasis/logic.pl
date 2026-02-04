#!/usr/bin/env perl
use strict;
use warnings;

# CONFIGURATION
# ================================

# Time format: HH:MM (24-hour)
use constant {
    WORK_START  => "06:00",
    WORK_END    => "16:00",
    SLEEP_START => "20:00",
    SLEEP_END   => "04:00"
};

# ================================

# HH:MM -> minutes
sub time_to_minutes {
    my ($time) = @_;
    my ($hour, $minute) = split /:/, $time;
    return $hour * 60 + $minute;
}

# if now is between start and end
sub in_time_range {
    my ($now, $start, $end) = @_;
    if ($start <= $end) {
        # Normal range (same day)
        return $now >= $start && $now < $end;
    }
    else {
        # Overnight range (e.g. 23:00 → 06:00)
        return $now >= $start || $now < $end;
    }
}

sub get_action_for_time {
    my ($current_minutes) = @_;

    my %t = (
        work_start  => time_to_minutes(WORK_START),
        work_end    => time_to_minutes(WORK_END),
        sleep_start => time_to_minutes(SLEEP_START),
        sleep_end   => time_to_minutes(SLEEP_END)
    );

    my $is_work_time = in_time_range($current_minutes, $t{work_start}, $t{work_end});
    my $is_sleep_time = in_time_range($current_minutes, $t{sleep_start}, $t{sleep_end});

    if ($is_work_time) {
        return 'systemctl suspend';
    }
    elsif ($is_sleep_time) {
        return 'systemctl poweroff';
    }
    else {
        return 'systemctl suspend';
    }
}

sub get_action_for_current_time {
    my ($sec, $min, $hour) = localtime;
    my $current_minutes = $hour * 60 + $min;
    return get_action_for_time($current_minutes);
}

# MAIN
# ================================

my $action = get_action_for_current_time();
system($action);
