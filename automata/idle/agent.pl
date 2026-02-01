#!/usr/bin/env perl

my $TIMEOUT_MINOR = 15;
my $TIMEOUT_MAJOR = 30;

sub minutes {
    my ($minutes) = @_;
    return $minutes * 60;
}

my @cmd = (
    "swayidle", "-w",
    "timeout", minutes($TIMEOUT_MINOR), "hyprctl dispatch dpms off",
    "resume", "hyprctl dispatch dpms on",
    "timeout", minutes($TIMEOUT_MAJOR), "hyprctl dispatch dpms on; sleep 1; perl ~/automata/idle/logic.pl",
    "resume", "hyprctl dispatch dpms on"
);
exec @cmd or die "Failed to exec swayidle: $!";
