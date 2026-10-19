#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use Logic qw(
    data_file
    load_data
    minute_to_hm
    now_minute
    save_data
    update_point
);

my $CACHE_FILE = data_file();

sub get_brightness {
    my $val = `brillo`;
    chomp $val;
    return $val || 0;
}

sub save_point {
    my ($min, $val) = @_;

    # Load, update and save back through the shared Logic helpers
    my $data = load_data($CACHE_FILE);
    update_point($data, $min, $val);
    save_data($CACHE_FILE, $data);

    printf "Saved: %s -> %.2f%%\n", minute_to_hm($min), $val;
}

# Get current time and brightness
my $current_min = now_minute();
my $current_br  = get_brightness();

save_point($current_min, $current_br);
