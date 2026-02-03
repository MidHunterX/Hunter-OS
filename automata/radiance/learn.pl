#!/usr/bin/env perl
use strict;
use warnings;

use JSON::PP;
use File::Spec;
use POSIX qw(strftime);

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use logic qw(update_point);

my $CACHE_FILE = File::Spec->catfile($ENV{HOME}, '.cache', 'radiance_data.json');

sub get_brightness {
    my $val = `brillo`;
    chomp $val;
    return $val || 0;
}

sub save_point {
    my ($min, $val) = @_;

    # Load existing
    my $data = {};
    if (-e $CACHE_FILE) {
        open my $fh, '<', $CACHE_FILE;
        local $/;
        $data = decode_json(<$fh> || '{}');
        close $fh;
    }

    # Update point
    $data = update_point($data, $min, $val);

    # Save back
    open my $fh, '>', $CACHE_FILE or die $!;
    print $fh encode_json($data);
    close $fh;

    printf "Saved: %02d:%02d -> %.2f%%\n", int($min/60), $min%60, $val;
}

# Get current time and brightness
my ($h, $m) = (strftime("%H", localtime), strftime("%M", localtime));
my $current_min = ($h * 60) + $m;
my $current_br  = get_brightness();

save_point($current_min, $current_br);
