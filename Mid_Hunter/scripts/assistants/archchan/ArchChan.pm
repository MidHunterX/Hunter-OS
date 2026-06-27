package ArchChan;

use strict;
use warnings;
use utf8;
use POSIX qw(strftime);
use Term::ANSIColor qw(:constants);
use Time::HiRes qw(sleep);
use Exporter 'import';
binmode(STDOUT, ":encoding(UTF-8)"); # Force UTF-8 for W-I-D-E (>255) print

our @EXPORT = qw(execute_command animate_message animate_prompt $C_CMD $C_OPT $C_VAR $C_STR $C_PROC $C_RST);

our $transient_prompt = ""
. RESET . RED . "█"
. BOLD . BLACK . ON_RED . strftime("%H:%M", localtime) . " "
. RESET . RED . ""
. RESET . BRIGHT_BLACK . ""
. RESET;

# Colors
our $C_BG    = ON_BLACK;
our $C_CMD   = BOLD . BLUE;
our $C_OPT   = BOLD . CYAN;
our $C_VAR   = BOLD . RED;
our $C_STR   = BOLD . YELLOW;
our $C_PROC  = BOLD . MAGENTA;
our $C_RST   = RESET;

my $NAME           = "Arch Chan";
my $MESSAGE_PROMPT = BOLD . GREEN . $NAME . ":" . RESET;

# Execute a command with syntax highlighting and a transient prompt
sub execute_command {
    my ($command) = @_;
    # Syntax highlight
    my $text = $command;
    $text =~ s/^(\S+)(.*?)$/$C_CMD$1$C_OPT$2${C_RST}/g;
    $text =~ s/"(.+?)"/${C_STR}"$1"${C_OPT}/g;
    print "\n${transient_prompt} ${text}\n";
    # Execute
    system($command);
    print "\n";
}

sub animate_message {
    my ($text, $newline) = @_;
    $newline = 1 unless defined $newline;

    print "${MESSAGE_PROMPT} ";

    # Syntax highlight
    $text =~ s/`(\S+)(.*?)`/$C_BG $C_CMD$1$C_OPT$2 ${C_RST}/g;
    $text =~ s/<([^>]+)>/${C_VAR}<$1>${C_OPT}/g;
    $text =~ s/''(.+?)''/${C_STR}"$1"${C_OPT}/g;
    $text =~ s/\*(\S+)\*/${C_RST}${C_CMD}$1${C_RST}/g;

    foreach my $word (split(/ /, $text)) {
        print "$word ";
        $| = 1;
        sleep(0.08);
    }

    print "\n" if $newline;
}

sub animate_prompt {
    my ($question) = @_;
    animate_message($question, 0);
    print BOLD . YELLOW . "(y/N) > " . RESET;
    my $input = <STDIN>;
    chomp($input);
    return ($input =~ /^[yY]/) ? 1 : 0;
}

1;
