#!/usr/bin/env perl
use strict;
use warnings;

use Time::HiRes qw(sleep);

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(
    data_file
    fval
    interpolate_brightness
    load_data
    minute_to_hm
    now_minute
);
use Weather qw(cached_delta);

# ============================== CONFIGURATION ============================== #

my $INTERVAL_MINS           = 5;  # How often to update brightness
my $WEATHER_REFRESH_MINS    = 30;  # Time to wait before updating weather cache
my $CACHE_FILE              = data_file();
my $BRIGHTNESS_CMD          = "brillo -u 5000000 -S";
my $TOGGLE_LOCK_FILE        = "/tmp/ai_brightness_toggle.lock";

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

sub weather_note {
    my ($weather) = @_;
    return "weather n/a" unless $weather;
    return "weather disabled (no coords in .env)" if $weather->{disabled};
    my $note = sprintf("weather code %d, cloud %d%%, %+d%%",
        fval($weather->{weather_code}), fval($weather->{cloud_cover}), fval($weather->{delta}));
    $note .= " (cached)" if $weather->{stale};
    return $note;
}

sub refresh_screen_brightness {
    if (-e $TOGGLE_LOCK_FILE) {
        return;
    }

    my $data = load_data($CACHE_FILE);
    my $now = now_minute();

    my $base_br = interpolate_brightness($data, $now);

    my $weather = cached_delta($WEATHER_REFRESH_MINS * 60);
    my $delta   = $weather ? fval($weather->{delta}) : 0;

    my $target_br = $base_br + $delta;
    $target_br = 0   if $target_br < 0;
    $target_br = 100 if $target_br > 100;

    printf "Time: %s | Base: %.2f%% | %s | Target: %.2f%%\n",
        minute_to_hm($now), $base_br, weather_note($weather), $target_br;
    system("$BRIGHTNESS_CMD $target_br");
}

# BEHAVIOR: continuous refresh loop
while (1) {
    refresh_screen_brightness();
    sleep($INTERVAL_MINS * 60);
}
