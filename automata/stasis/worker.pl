#!/usr/bin/env perl
use strict;
use warnings;

use constant {
    TIMEOUT_MINOR => 15,
    TIMEOUT_MAJOR => 30
};

sub minutes {
    my ($minutes) = @_;
    return $minutes * 60;
}

my $HOME = $ENV{HOME} // die "HOME environment variable is not set";

my @cmd = (
    "swayidle", "-w",
    "timeout", minutes(TIMEOUT_MINOR), "perl $HOME/automata/stasis/logic.pl --minor",
    "resume", "hyprctl dispatch dpms on; perl $HOME/automata/radiance/worker.pl --once",
    "timeout", minutes(TIMEOUT_MAJOR), "hyprctl dispatch dpms on; sleep 1; perl $HOME/automata/stasis/logic.pl",
    "resume", "hyprctl dispatch dpms on; perl $HOME/automata/radiance/worker.pl --once"
);
exec @cmd or die "Failed to exec swayidle: $!";
