#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(setsid);

my $DAEMON_NAME = "voxtype"; # The expected process name to check for
my $DAEMON_CMD  = "voxtype"; # The command to start the daemon
my $TIMER_DELAY = 60 * 5;    # seconds before killing the daemon

# HELPER FUNCTIONS

sub is_daemon_running {
    my $count = `pgrep -x "$DAEMON_NAME"`;
    return $count > 0;
}

sub start_daemon_if_needed {
    unless (is_daemon_running()) {
        print "Daemon not running. Starting '$DAEMON_CMD'...\n";
        system("nohup $DAEMON_CMD &>/dev/null &");
        sleep 0.5;
    }
}

sub kill_daemon {
    if (is_daemon_running()) {
        print "Killing daemon '$DAEMON_NAME'...\n";
        system("pkill -x '$DAEMON_NAME'");
    }
}

sub start_cleanup_timer {
    my $pid = fork();

    if (!defined $pid) {
        die "Could not fork for timer: $!";
    } elsif ($pid == 0) {
        setsid();
        print "Timer started: will kill daemon in $TIMER_DELAY seconds unless reset...\n";
        sleep $TIMER_DELAY;
        kill_daemon();
        exit 0; # Important to exit the child process
    }
    # Parent process continues
}

# MAIN LOGIC

my $action = shift @ARGV;

if ($action eq "start") {
    start_daemon_if_needed();
    system("voxtype record start &>/dev/null &");
    print "Recording started.\n";
    system("pkill -f 'hypr/scripts/whisper.pl stop' 2>/dev/null");
} elsif ($action eq "stop") {
    system("voxtype record stop &>/dev/null &");
    print "Recording stopped.\n";
    start_cleanup_timer();
} else {
    die "Usage: $0 [start|stop]\n";
}

exit 0;
