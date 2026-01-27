#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use File::Spec;
use POSIX qw(strftime);
use Time::HiRes qw(sleep);

# ============================== CONFIGURATION ============================== #

my $INTERVAL_MINS = 5; # How often to update brightness
my $CACHE_FILE    = File::Spec->catfile($ENV{HOME}, '.cache', 'brightness_data.json');
my $BRIGHTNESS_CMD    = "brillo -u 5000000 -S";

# =========================================================================== #

# CHECK: single instance
my $lock_file = "/tmp/ai_brightness.lock";
if (-e $lock_file) {
    open my $fh, '<', $lock_file;
    my $pid = <$fh>;
    if ($pid && kill(0, $pid)) { die "Already running with PID $pid\n"; }
}
open my $fh, '>', $lock_file or die $!;
print $fh $$;
close $fh;

sub load_data {
    if (!-e $CACHE_FILE) { return {}; }
    open my $fh, '<', $CACHE_FILE or return {};
    local $/;
    my $json_text = <$fh>;
    close $fh;
    return decode_json($json_text || '{}');
}

sub get_minutes_since_midnight {
    my ($h, $m) = (strftime("%H", localtime), strftime("%M", localtime));
    return ($h * 60) + $m;
}

sub interpolate_brightness {
    my ($data, $current_min) = @_;

    my @stored_mins = sort { $a <=> $b } keys %$data;

    # SCENARIO No dataset
    return 0 if (!@stored_mins);

    # SCENARIO Exact match
    return $data->{$current_min} if exists $data->{$current_min};

    my ($prev, $next);
    for my $m (@stored_mins) {
        if ($m < $current_min) { $prev = $m; }
        if ($m > $current_min && !defined $next) { $next = $m; }
    }

    # CASE: Time Wrap-around (Midnight)
    # If no prev, the "prev" is the last point of the previous day
    if (!defined $prev) {
        $prev = $stored_mins[-1];
        my $val_prev = $data->{$prev};
        my $val_next = $data->{$stored_mins[0]};

        my $dist_total = (1440 - $prev) + $stored_mins[0];
        my $dist_curr  = ($current_min < $prev) ? $current_min + (1440 - $prev) : $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # If no next, the "next" is the first point of the next day
    if (!defined $next) {
        $next = $stored_mins[0];
        my $val_prev = $data->{$prev};
        my $val_next = $data->{$next};

        my $dist_total = (1440 - $prev) + $next;
        my $dist_curr  = $current_min - $prev;

        return $val_prev + ($val_next - $val_prev) * ($dist_curr / $dist_total);
    }

    # LERP (Linear Interpolation)
    my $val_prev = $data->{$prev};
    my $val_next = $data->{$next};
    return $val_prev + ($val_next - $val_prev) * (($current_min - $prev) / ($next - $prev));
}

# =============================== MAIN LOGIC =============================== #

while (1) {
    my $data = load_data();
    my $now  = get_minutes_since_midnight();

    my $target_br = interpolate_brightness($data, $now);

    printf "Time: %02d:%02d | Target: %.2f%%\n", int($now/60), $now%60, $target_br;

    system("$BRIGHTNESS_CMD $target_br");

    sleep($INTERVAL_MINS * 60);
}
