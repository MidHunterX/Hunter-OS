#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;

# # BENCHMARK START
# my $benchmark_start = `date +%N`;
# chomp $benchmark_start;

my $PLACEHOLDER_COLOR = '#2e3436';
my $CSS_FILE   = "$ENV{HOME}/.config/wlogout/colors.css";
my $ICON_DIR   = "$ENV{HOME}/.config/wlogout/icons";
my $OUTPUT_DIR = "$ENV{HOME}/.config/wlogout/color_icons";

# Exit if CSS file doesn't exist
exit 0 unless -f $CSS_FILE;

# Create output directory if needed
mkdir $OUTPUT_DIR unless -d $OUTPUT_DIR;

# Extract PRIMARY_COLOR from CSS
my $PRIMARY_COLOR;
open my $css, '<', $CSS_FILE or die "Can't open CSS file: $!";
while (<$css>) {
	if (/^\@define-color\s+primary\s+(\S+);/) {
		$PRIMARY_COLOR = $1;
		last;
	}
}
close $css;

# If not found, exit harmlessly
exit 0 unless defined $PRIMARY_COLOR;

# Process SVG files
opendir(my $dh, $ICON_DIR) or die "Can't open icon dir: $!";
while (my $file = readdir($dh)) {
	next unless $file =~ /\.svg$/;
	my $src = "$ICON_DIR/$file";
	my $dst = "$OUTPUT_DIR/$file";

	open my $in,  '<', $src or die "Can't read $src: $!";
	open my $out, '>', $dst or die "Can't write $dst: $!";

	while (<$in>) {
		s/fill="$PLACEHOLDER_COLOR"/fill="$PRIMARY_COLOR"/g;
		print $out $_;
	}

	close $in;
	close $out;
}
closedir($dh);

# # BENCHMARK END
# my $benchmark_end = `date +%N`;
# chomp $benchmark_end;
# my $start_ms = substr($benchmark_start, 0, -6);
# my $end_ms   = substr($benchmark_end,   0, -6);
# my $elapsed  = $end_ms - $start_ms;
# print "${elapsed}ms\n";
