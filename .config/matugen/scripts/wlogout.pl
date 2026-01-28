#!/usr/bin/env perl

use strict;
use warnings;
use File::Basename;

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
        $PRIMARY_COLOR =~ s/\s+$//; # Clean trailing whitespace
        last;
    }
}
close $css;

# If not found, exit harmlessly
exit 0 unless defined $PRIMARY_COLOR;


# Create a sanitized directory name from the color (e.g., #2e3436 -> 2e3436)
my $COLOR_NAME = $PRIMARY_COLOR;
$COLOR_NAME =~ s/[^A-Za-z0-9]//g;
my $COLOR_DIR = "$OUTPUT_DIR/$COLOR_NAME";

# Ensure the base and color-specific directories exist
mkdir $OUTPUT_DIR unless -d $OUTPUT_DIR;
mkdir $COLOR_DIR  unless -d $COLOR_DIR;

# Process SVG files
opendir(my $dh, $ICON_DIR) or die "Can't open icon dir: $!";
while (my $file = readdir($dh)) {
    next unless $file =~ /\.svg$/;

    my $src    = "$ICON_DIR/$file";
    my $cached = "$COLOR_DIR/$file";
    my $link   = "$OUTPUT_DIR/$file";

    # Store in color-specific dir IF NOT already there
    if (! -f $cached) {
        open my $in,  '<', $src or die "Can't read $src: $!";
        open my $out, '>', $cached or die "Can't write $cached: $!";

        while (<$in>) {
            s/fill="$PLACEHOLDER_COLOR"/fill="$PRIMARY_COLOR"/g;
            print $out $_;
        }

        close $in;
        close $out;
    }

    # Reference with links instead of re-generation
    # Remove existing file or stale link first
    if (-e $link || -l $link) {
        unlink $link or die "Could not remove existing link/file $link: $!";
    }

    # Create symlink from the output dir to the color-specific cached file
    # (Using a relative path for the link target to keep the folder structure portable)
    symlink("$COLOR_NAME/$file", $link) or warn "Could not create link for $file: $!";
}
closedir($dh);
