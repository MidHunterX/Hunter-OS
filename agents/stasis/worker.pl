#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use Vars qw(TIMEOUT_MAJOR TIMEOUT_MINOR);

sub seconds {
    my ($minutes) = @_;
    return $minutes * 60;
}

my $HOME = $ENV{HOME} // die "HOME environment variable is not set";

my $SCREEN_ON = "hyprctl dispatch 'hl.dsp.dpms({action=\"enable\"})'";
my $SCREEN_OFF = "hyprctl dispatch 'hl.dsp.dpms({action=\"disable\"})'";
my $LOGIC = "perl $HOME/agents/stasis/logic.pl";
my $RADIANCE = "perl $HOME/agents/radiance/worker.pl";

my @cmd = (
    "swayidle", "-w",
    "timeout", seconds(TIMEOUT_MINOR), "$SCREEN_OFF",
    "resume", "$SCREEN_ON; $RADIANCE --once",
    "timeout", seconds(TIMEOUT_MAJOR), "$SCREEN_ON; sleep 1; $LOGIC",
    "resume", "$SCREEN_ON; $RADIANCE --once; expression --once"
);
exec @cmd or die "Failed to exec swayidle: $!";
