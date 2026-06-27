#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/..";
use ArchChan;

my $skipped = 0;

# ACTION: UNWANTED PACKAGES
my $pkg_count = `pacman -Qdtq | wc -l`;
if ($pkg_count != 0) {
    animate_message('Take a look at this...');
    execute_command('pacman -Qdtq');
    if (animate_prompt('Wanna yeet these packages?')){
        animate_message('Okay, here we go...');
        execute_command('sudo pacman -R $(pacman -Qdtq)');
        animate_message('All squeaky clean!');
    } else {
        animate_message('I see. You can always run `sudo pacman -R $(pacman -Qdtq)` any time.');
        $skipped = 1;
    }
}


# ACTION: PACKAGE CACHE
my $cache_output = `paccache --keep 2 --dryrun`;
if ($cache_output =~ /(\d+) candidates.*disk space saved: ([\d.]+) MiB/s) {
    # ==> finished dry run: 77 candidates (disk space saved: 602.84 MiB)
    my $cache_count = $1;
    my $cache_size  = $2;
    animate_message("There's some space to clean up...");
    execute_command("paccache --keep 2 --dryrun");
    if (animate_prompt("Free up $cache_size MB?")) {
        execute_command("paccache -r --keep 2");
    } else {
        animate_message("No worries, I'll leave the cache alone.");
        $skipped = 1;
    }
} elsif ($cache_output =~ /no candidate packages found for pruning/s) {
    # ==> no candidate packages found for pruning
} else {
    warn "Could not parse paccache output";
}


# ACTION: YAY CACHE
my $yay_cache = "$ENV{HOME}/.cache/yay";
if (-d $yay_cache) {
    animate_message("Cleaning up Yay cache...");
    execute_command("rm -rf $yay_cache");
}


# CLEANUP: SUDO
my $sudo_check = system("sudo -n -v 2>/dev/null");
if ($sudo_check == 0) {
    animate_message('Lemme just unsudo for you...');
    execute_command('sudo -k');
}


# FINISHED
if ($skipped == 1) {
    animate_message('Cya later!');
} else {
    animate_message('Everything is looking clean and fresh!');
}
