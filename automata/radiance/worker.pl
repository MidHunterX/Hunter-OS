#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;
use POSIX qw(strftime);
use Time::HiRes qw(sleep);

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(interpolate_brightness load_data);

# ============================== CONFIGURATION ============================== #

my $INTERVAL_MINS = 5;  # How often to update brightness
my $CACHE_FILE    = File::Spec->catfile($ENV{HOME}, '.cache', 'radiance_data.json');
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

# =============================== MAIN LOGIC =============================== #

while (1) {
    my $data = load_data($CACHE_FILE);
    my ($h, $m) = (strftime("%H", localtime), strftime("%M", localtime));
    my $now = ($h * 60) + $m;

    my $target_br = interpolate_brightness($data, $now);

    printf "Time: %02d:%02d | Target: %.2f%%\n", int($now/60), $now%60, $target_br;
    system("$BRIGHTNESS_CMD $target_br");
    sleep($INTERVAL_MINS * 60);
}
