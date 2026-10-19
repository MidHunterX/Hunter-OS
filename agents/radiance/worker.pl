#!/usr/bin/env perl
use strict;
use warnings;

use Time::HiRes qw(sleep);

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(
    data_file
    interpolate_brightness
    load_data
    minute_to_hm
    now_minute
);

# ============================== CONFIGURATION ============================== #

my $INTERVAL_MINS = 5;  # How often to update brightness
my $CACHE_FILE    = data_file();
my $BRIGHTNESS_CMD    = "brillo -u 5000000 -S";
my $TOGGLE_LOCK_FILE  = "/tmp/ai_brightness_toggle.lock";

# ============================== COMMAND LINE ============================== #
use Getopt::Long;

my $flag_once = 0;
my $flag_toggle = 0;
GetOptions(
    "once" => \$flag_once, # Only run once and exit. Basically update.
    "toggle" => \$flag_toggle # Toggle worker lock
);

if ($flag_once) {
    refresh_screen_brightness();
    exit 0;
}

if ($flag_toggle) {
    if (-e $TOGGLE_LOCK_FILE) {
        unlink $TOGGLE_LOCK_FILE or die "Could not remove lock: $!\n";
        system("notify-send", "-r", "69", " Radiance unlocked");
        refresh_screen_brightness();
    } else {
        open my $fh, '>', $TOGGLE_LOCK_FILE or die "Could not create lock: $!\n";
        print $fh "LOCKED\n";
        close $fh;
        system("notify-send", "-r", "69", " Radiance locked");
    }
    exit 0;
}

# =========================================================================== #

# CHECK: single instance
my $lock_file = "/tmp/ai_brightness.lock";
if (-e $lock_file) {
    open my $fh, '<', $lock_file;
    my $pid = <$fh>;
    if ($pid && kill(0, $pid)) { die "Already running with PID $pid\n"; }
}

# REQUIRE: single instance lock file
open my $fh, '>', $lock_file or die $!;
print $fh $$;
close $fh;

# =============================== MAIN LOGIC =============================== #

sub refresh_screen_brightness {
    if (-e $TOGGLE_LOCK_FILE) {
        return;
    }

    my $data = load_data($CACHE_FILE);
    my $now = now_minute();

    my $target_br = interpolate_brightness($data, $now);

    printf "Time: %s | Target: %.2f%%\n", minute_to_hm($now), $target_br;
    system("$BRIGHTNESS_CMD $target_br");
}

# BEHAVIOR: continuous refresh loop
while (1) {
    refresh_screen_brightness();
    sleep($INTERVAL_MINS * 60);
}
