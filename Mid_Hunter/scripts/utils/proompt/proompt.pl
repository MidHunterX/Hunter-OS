#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use FindBin;            # locate script directory
use lib $FindBin::Bin;  # add directory to the search path (@INC) for lib
use lib dirname(__FILE__) . '/lib';
use Proompt qw(process_markdown);

my $input_file = shift || 'PROOMPT.md';

if (!-f $input_file) {
    die "Usage: $0 [input_file]\nError: File '$input_file' not found.\n";
}

# READ
open my $fh, '<', $input_file or die $!;
my @input_lines = <$fh>;
close $fh;

# PROCESS
my @updated = process_markdown(@input_lines);

# WRITE
open my $out, '>', $input_file or die $!;
print $out @updated;
close $out;
