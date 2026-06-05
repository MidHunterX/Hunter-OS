#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece; # Required for parsing timestamps
use FindBin;
use lib $FindBin::Bin;
use Vars qw(TIMEOUT_MAJOR TIMEOUT_MINOR DAYS_TO_LOOK_BACK FALLBACK_START FALLBACK_END);

# HH:MM -> minutes
sub time_to_minutes {
    my ($time) = @_;
    my ($hour, $minute) = split /:/, $time;
    return $hour * 60 + $minute;
}

# minutes -> HH:MM
sub minutes_to_time {
    my ($min) = @_;
    $min %= 1440; # Wrap around 24h
    return sprintf("%02d:%02d", int($min / 60), $min % 60);
}

# if now is between start and end
sub in_time_range {
    my ($now, $start, $end) = @_;
    return ($start <= $end)
        ? ($now >= $start && $now < $end) # Normal range (same day)
        : ($now >= $start || $now < $end); # Overnight range (23:00 -> 06:00)
}

# retrieve historical boot start and end times
sub get_boot_times {
    my ($days_limit) = @_;

    my @start_times;
    my @end_times;

    my $cutoff_time = localtime(time - ($days_limit * 86400));

    # Fetch the list of recorded boots from systemd
    # Gracefully return empty arrays if journalctl fails or permission is denied
    open(my $fh, '-|', 'journalctl', '--list-boots') or return (\@start_times, \@end_times);

    while (my $line = <$fh>) {
        chomp $line;
        my ($idx) = $line =~ /^\s*(-?\d+)/;
        next unless defined $idx;

        my @dates = $line =~ /(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}):\d{2}/g;
        next unless @dates >= 4;

        my ($start_date, $start_time, $end_date, $end_time) = @dates;

        my $t_start;
        eval {
            $t_start = localtime->strptime("$start_date $start_time:00", "%Y-%m-%d %H:%M:%S");
        };
        next if $@;
        next if $t_start < $cutoff_time;

        push @start_times, $start_time;

        # Exclude active boot (idx 0) from shutdown times to avoid calculation skew
        if ($idx != 0) {
            my $skew_correction_min = TIMEOUT_MAJOR + TIMEOUT_MINOR;
            my $end_min = time_to_minutes($end_time) - $skew_correction_min;
            push @end_times, minutes_to_time($end_min);
        }
    }
    close($fh);

    return (\@start_times, \@end_times);
}

sub calculate_median_time {
    my ($times_ref, $fallback) = @_;
    return $fallback unless @$times_ref;
    my @minutes;
    for my $time_str (@$times_ref) {
        push @minutes, time_to_minutes($time_str);
    }
    @minutes = sort { $a <=> $b } @minutes;
    my $count = scalar @minutes;
    my $median_min;
    if ($count % 2 == 1) {
        $median_min = $minutes[int($count / 2)];
    } else {
        $median_min = ($minutes[($count / 2) - 1] + $minutes[$count / 2]) / 2;
    }
    my $median_h = int($median_min / 60);
    my $median_m = int($median_min % 60);
    return sprintf("%02d:%02d", $median_h, $median_m);
}

sub get_action_for_time {
    my ($current_minutes, $work_start, $work_end) = @_;

    my %t = (
        work_start => time_to_minutes($work_start),
        work_end   => time_to_minutes($work_end),
    );

    my $is_work_time = in_time_range($current_minutes, $t{work_start}, $t{work_end});

    if ($is_work_time) {
        # Keep workstation active and ready to deploy at all times
        return 'systemctl suspend';
    } else {
        return 'systemctl poweroff';
    }
}

sub get_action_for_current_time {
    my ($work_start, $work_end) = @_;
    my ($sec, $min, $hour) = localtime;
    my $current_minutes = $hour * 60 + $min;
    return get_action_for_time($current_minutes, $work_start, $work_end);
}


# MAIN
# ================================

my ($start_times_ref, $end_times_ref) = get_boot_times(DAYS_TO_LOOK_BACK);
my $dynamic_start = calculate_median_time($start_times_ref, FALLBACK_START);
my $dynamic_end   = calculate_median_time($end_times_ref, FALLBACK_END);
my $action = get_action_for_current_time($dynamic_start, $dynamic_end);

# print "{\n Current_Action\t: $action\n Work_Start\t: $dynamic_start\n Work_End\t: $dynamic_end\n}";
system($action);
