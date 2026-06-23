#!/usr/bin/env perl

# Requires: perl-yaml-libyaml

use strict;
use warnings;
use utf8;
use YAML::XS qw(LoadFile);
use Term::ANSIColor qw(:constants);
use Time::HiRes qw(sleep);
use IPC::Open2;
use FindBin;
binmode(STDOUT, ":encoding(UTF-8)"); # Force UTF-8 for W-I-D-E (>255) print

use lib $FindBin::Bin;
use ArchChan;

# Configuration
my $DATA_FILE   = "$FindBin::Bin/commands.yaml";
my $PROMPT      = "Arch Chan's Command Shop";

sub main {
    # REQUIRE: DATA_FILE
    die "Missing $DATA_FILE" unless -e $DATA_FILE;
    my $data = LoadFile($DATA_FILE);

    # REQUIRE: item selection
    my @keywords = map { $_->{keyword} } @$data;
    my $pid = open2(my $fzf_out, my $fzf_in, "fzf --border rounded --border-label \"$PROMPT\"");
    print $fzf_in join("\n", @keywords);
    close($fzf_in);
    my $selection = <$fzf_out>;
    chomp($selection) if $selection;
    waitpid($pid, 0);

    unless ($selection) {
        animate_message("Nothing to do... Have a nice day, master ;D");
        exit 0;
    }

    my ($entry) = grep { $_->{keyword} eq $selection } @$data;

    # ACTION: Commands
    if ($entry->{commands}) {
        my @cmds = ref($entry->{commands}) eq 'ARRAY' ? @{$entry->{commands}} : ($entry->{commands});
        foreach my $cmd (@cmds) {
            execute_command($cmd);
        }
    }

    # ACTION: Procedure
    if ($entry->{procedure}) {
        my $proc_name = $entry->{procedure};
        my $proc_path = "$FindBin::Bin/procedures/$proc_name";

        if (-f "$proc_path.pl") {
            system("perl", "$proc_path.pl");
        } elsif (-f "$proc_path.sh") {
            system("bash", "$proc_path.sh");
        } else {
            print "Procedure $proc_name not found.\n";
        }
    }

    # ACTION: Comment
    if ($entry->{comment}) {
        animate_message($entry->{comment});
    }
}

main();
