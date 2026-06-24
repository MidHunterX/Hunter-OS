#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;

use lib dirname(File::Spec->rel2abs($0));
use MenuLib qw(get_cache_dir update_emojis show_menu switch_if_menu bump_to_top send_output);

my $LABEL = "Emoji Menu";
my $CACHE_DIR = get_cache_dir();
my $CACHE_FILE = File::Spec->catfile($CACHE_DIR, "emojis.txt");

if (! -s $CACHE_FILE) { update_emojis($CACHE_FILE); }

my $row = show_menu($CACHE_FILE, "󰱨", $LABEL, "#f9e2afff");

exit unless defined $row && length $row;

if (switch_if_menu($row)) { exit; }

my ($symbol) = split(' ', $row, 2);
send_output($symbol);
bump_to_top($row, $CACHE_FILE);
