#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(setsid);

my $DAEMON_NAME = "voxtype"; # The expected process name to check for
my $DAEMON_CMD  = "voxtype"; # The command to start the daemon
my $TIMER_DELAY = 60 * 5;    # seconds before killing the daemon

# HELPER FUNCTIONS

sub is_daemon_running {
    my $count = `pgrep -cx "$DAEMON_NAME"`;
    chomp $count;
    return $count > 0;
}

sub is_daemon_ready {
    my $status = `voxtype status`;
    chomp $status;
    return $status eq "idle";
}

sub wait_for_daemon {
    my $timeout = shift // 10;  # Allow timeout to be passed as parameter
    my $check_interval = shift // 0.2;
    print "Waiting for daemon to be ready (timeout: ${timeout}s)...\n";
    if (!is_daemon_running()) {
        die "Daemon is not running. Cannot wait for readiness.\n";
    }
    my $start_time = time();
    while (time() - $start_time < $timeout) {
        if (is_daemon_ready()) {
            print "Daemon is ready.\n";
            return 1;
        }
        sleep $check_interval;
    }
    die "Timed out waiting for daemon to be ready after ${timeout}s.\n";
}

sub start_daemon_if_needed {
    unless (is_daemon_running()) {
        print "Daemon not running. Starting '$DAEMON_CMD'...\n";
        system("nohup $DAEMON_CMD &>/dev/null &");
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
    wait_for_daemon();
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
