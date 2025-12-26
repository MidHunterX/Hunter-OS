#!/usr/bin/env perl
use strict;
use warnings;

sub no_escape {
	my ($s) = @_;
	$s =~ s/\033/\\033/g;
	return $s;
}

# COLOR LIBRARY
my $FG_BLK = "\033[1;30m"; my $FG_RED = "\033[1;31m"; my $FG_GRN = "\033[1;32m"; my $FG_YLO = "\033[1;33m";
my $FG_BLU = "\033[1;34m"; my $FG_PNK = "\033[1;35m"; my $FG_CYN = "\033[1;36m"; my $FG_WHT = "\033[1;37m";
my $BG_BLK = "\033[1;40m"; my $BG_RED = "\033[1;41m"; my $BG_GRN = "\033[1;42m"; my $BG_YLO = "\033[1;43m";
my $BG_BLU = "\033[1;44m"; my $BG_PNK = "\033[1;45m"; my $BG_CYN = "\033[1;46m"; my $BG_WHT = "\033[1;47m";
my $RESET  = "\033[0;0m";  my $UNDERLINE = "\033[4m"; my $X = $RESET;

# PROMPT DESIGNS
sub prompt_normal {
	my ($user, $host, $port, $dbname, $cmd, $session, $transaction) = @_;
	my $prompt = '';
	$prompt  = "${FG_GRN}${user}\@${host}:${port}${X}/";
	$prompt .= "${FG_PNK}${dbname}${X}";
	$prompt .= "${cmd}${session}${transaction} ";
	return $prompt;
}

sub prompt_bubble {
	my ($user, $host, $port, $dbname, $cmd, $session, $transaction) = @_;
	my $prompt = '';
	$prompt  = "${FG_GRN}${X}${FG_BLK}${BG_GRN} ${user}\@${host}:${port} ${X}${FG_GRN}${X} ";
	$prompt .= "${FG_PNK}${dbname}${X} ";
	$prompt .= "${FG_BLK}${BG_YLO} ${cmd}${session}${transaction} ${X}${FG_YLO}${X} ";
	return $prompt;
}

# SYSTEM VARIABLES (EXAMPLE OUTPUT)
my $user        = $ENV{USER} // 'user';
my $host        = '[local]';
my $port        = '5432';
my $dbname      = 'dbname';
my $cmd         = '=';
my $session     = '#';
my $transaction = '';

my $theme_normal = prompt_normal($user, $host, $port, $dbname, $cmd, $session, $transaction);
my $theme_bubble = prompt_bubble($user, $host, $port, $dbname, $cmd, $session, $transaction);

print "PREVIEW:\n";
print "Normal: $theme_normal\n";
print "Bubble: $theme_bubble\n\n";

# POSTGRES VARIABLES (CODE)
$user        = '%n';
$host        = '%M';
$port        = '%>';
$dbname      = '%/';  # short: "%~"
$cmd         = '%R';  # = (normal), @ (inactive), ^ (single-line), ! (disconnected) depending on session state
$session     = '%#';  # > (unprevileged), # (superuser)
$transaction = '%x';  # * (inside transaction), ! (failed transaction) depending on transaction state

print "CODE:\n";
print "Normal: ", no_escape($theme_normal), "\n";
print "Bubble: ", no_escape($theme_bubble), "\n";
