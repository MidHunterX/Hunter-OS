#!/usr/bin/env perl

# Requires: perl-yaml-libyaml

use strict;
use warnings;
use utf8;
use POSIX qw(strftime);
use YAML::XS qw(LoadFile);
use Term::ANSIColor qw(:constants);
use Time::HiRes qw(sleep);
use IPC::Open2;
use FindBin;
binmode(STDOUT, ":encoding(UTF-8)"); # Force UTF-8 for W-I-D-E (>255) print


# Configuration
my $NAME        = "Arch Chan";
my $DATA_FILE   = "commands.yaml";
my $PROMPT      = "Arch Chan's Command Shop";

# Colors
my $C_BG    = ON_BLACK;
my $C_CMD   = BOLD . BLUE;
my $C_OPT   = BOLD . CYAN;
my $C_VAR   = BOLD . RED;
my $C_STR   = BOLD . YELLOW;
my $C_RST   = RESET;

# Prompts
my $transient_prompt = ""
. RESET . RED . "█"
. BOLD . BLACK . ON_RED . strftime("%H:%M", localtime) . " "
. RESET . RED . ""
. RESET . BRIGHT_BLACK . ""
. RESET;
my $message_prompt = BOLD . GREEN . $NAME . ":" . RESET;

sub animate_message {
    my ($text) = @_;

    print "\n${message_prompt} ";

    # Syntax highlight backticks
    $text =~ s/`(\S+)(.*?)`/$C_BG$C_CMD$1$C_OPT$2${C_RST}/g;
    $text =~ s/<([^>]+)>/${C_VAR}<$1>${C_OPT}/g;
    $text =~ s/''(.+?)''/${C_STR}"$1"${C_OPT}/g;

    foreach my $word (split(/ /, $text)) {
        print "$word ";
        $| = 1; # Flush output buffer
        sleep(0.09);
    }
    print "\n";
}

sub main {
    # REQUIRE: DATA_FILE
    $DATA_FILE = "$FindBin::Bin/commands.yaml";
    die "Missing $DATA_FILE" unless -e $DATA_FILE;
    my $data = LoadFile($DATA_FILE);

    # REQUIRE: item selection
    my @keywords = map { $_->{keyword} } @$data;
    my $selection;
    my $pid = open2(my $fzf_out, my $fzf_in, "fzf --border rounded --border-label \"$PROMPT\"");
    print $fzf_in join("\n", @keywords);
    close($fzf_in);
    $selection = <$fzf_out>;
    chomp($selection) if $selection;
    waitpid($pid, 0);
    # return unless $selection;
    unless ( $selection ) {
        animate_message("Nothing to do... Have a nice day, master ;D");
        exit 0;
    }

    my ($entry) = grep { $_->{keyword} eq $selection } @$data;

    # ACTION: Execute commands
    if ($entry->{commands}) {
        my @cmds = ref($entry->{commands}) eq 'ARRAY' ? @{$entry->{commands}} : ($entry->{commands});
        foreach my $cmd (@cmds) {
            my $f_cmd = $cmd;
            $f_cmd =~ s/^(\S+)(.*)$/$C_CMD$1$C_OPT$2/;
            print "\n${transient_prompt} ${C_RST}${C_CMD}$f_cmd${C_RST}\n";
            system($cmd);
        }
    }

    # ACTION: Comment
    if ($entry->{comment}) {
        animate_message($entry->{comment});
    }
}

main();
