#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Term::ANSIColor qw(:constants);

my $file = shift // 'README.adoc';
open my $fh, '<', $file;
my @lines = <$fh>;
close $fh;

my @packages;   # entry: { name => $name, src => $src }

my $in_table = 0;
my @table_lines;

sub is_header_row {
    my $row = shift;
    return 0 unless defined $row && $row =~ /\|/;

    my @cells = map { s/^\s+|\s+|\s+$//g; $_ } split /\|/, $row;
    return 0 if @cells < 3;

    my ($col1, $col2, $col3) = @cells[1,2,3];
    return 0 unless $col1 =~ /^PackageName$/i;
    return 0 unless $col2 =~ /^Description$/i;
    return 0 unless $col3 =~ /^Src$/i;
    # print "{$col1,$col2,$col3}\n";
    return 1;
}

sub process_table {
    my @rows = @_;
    my $blank_line_re = qr/^\s*$/;
    while (@rows && $rows[0] =~ $blank_line_re) { shift @rows; }
    return if @rows < 2;   # need at least header + one data row

    my $header = shift @rows;
    return unless is_header_row($header);

    foreach my $row (@rows) {
        next if $row =~ $blank_line_re;
        my @cells = map { s/^\s+|\s+$//g; $_ } split /\|/, $row;
        next if @cells < 4;
        my ($name, $desc, $src) = @cells[1,2,3];
        next unless $name && $src;
        $src = lc $src;
        next unless $src =~ /^(pacman|aur)$/;
        push @packages, { name => $name, src => $src };
        # print "$name ($src): $desc\n";
    }
}

# Parse the file
foreach my $line (@lines) {
    chomp $line;
    if ($line =~ /^\s*\|===\s*$/) {
        if ($in_table) {
            process_table(@table_lines);
            # foreach my$table_line(@table_lines){print$table_line,"\n";}print"-------------------------\n";
            @table_lines = ();
            $in_table = 0;
        } else {
            $in_table = 1;
            @table_lines = ();
        }
        next;
    }
    if ($in_table) {
        # Need to be in the format "| {name} | {description} | {src} |"
        my @cells = map { s/^|\s+|\s+|\s+$//g; $_ } split /\|/, $line;
        if (@cells > 3){
            # print$line,"\n-------------------------\n";
            push @table_lines, $line;
        };
    }
}
# in case file ends without closing table
process_table(@table_lines) if @table_lines;

my %explicitly_installed;
open my $pacman, '-|', 'pacman', '-Qqe' or die "Cannot run pacman: $!";
while (<$pacman>) {
    chomp;
    my ($name) = split /\s+/, $_, 2;
    $explicitly_installed{$name} = 1;
}
close $pacman;

my %all_installed;
open my $ultra_pacman, '-|', 'pacman', '-Qq' or die "Cannot run pacman: $!";
while (<$ultra_pacman>) {
    chomp;
    my ($name) = split /\s+/, $_, 2;
    $all_installed{$name} = 1;
}
close $ultra_pacman;

my %listed;
foreach my $pkg (@packages) {
    $listed{$pkg->{name}} = $pkg->{src};
}

my (@listed_not_installed, @installed_not_listed, @installed_and_listed);

foreach my $pkg (@packages) {
    if (exists $explicitly_installed{$pkg->{name}}) {
        push @installed_and_listed, $pkg;
    } elsif (exists $all_installed{$pkg->{name}}) {
        # It's installed, but not explicitly
        push @installed_and_listed, $pkg;
    } else {
        push @listed_not_installed, $pkg;
    }
}

foreach my $name (keys %explicitly_installed) {
    push @installed_not_listed, $name unless exists $listed{$name};
}

# Sort for readability
@listed_not_installed = sort { $a->{name} cmp $b->{name} } @listed_not_installed;
@installed_not_listed = sort @installed_not_listed;
@installed_and_listed = sort { $a->{name} cmp $b->{name} } @installed_and_listed;

# Output report
print BRIGHT_RED;
print "╭─────────────────────────────────────────╮\n";
print "│ 🔴 Packages in README but NOT INSTALLED │\n";
print "├─────────────────────────────────────────╯\n";
print RESET;
foreach my $pkg (@listed_not_installed) {
    printf BRIGHT_RED."│ ".RESET."%s".BRIGHT_BLACK." (%s)".RESET."\n", $pkg->{name}, $pkg->{src};
}
print "(none)\n" unless @listed_not_installed;

print "\n".BRIGHT_YELLOW;
print "╭─────────────────────────────────────────╮\n";
print "│ 🟡 Packages INSTALLED but NOT in README │\n";
print "├─────────────────────────────────────────╯\n";
print RESET;
foreach my $name (@installed_not_listed) {
    print BRIGHT_YELLOW."│ ".RESET."$name\n";
}
print "(none)\n" unless @installed_not_listed;

print "\n".BRIGHT_GREEN;
print "╭─────────────────────────────────────────╮\n";
print "│ 🟢 Packages in README and IS INSTALLED  │\n";
print "├─────────────────────────────────────────╯\n";
print RESET;
foreach my $pkg (@installed_and_listed) {
    printf BRIGHT_GREEN."│ ".RESET."%s".BRIGHT_BLACK." (%s)".RESET."\n", $pkg->{name}, $pkg->{src};
}
print "(none)\n" unless @installed_and_listed;

print "\nSummary:\n";
printf "  Listed: %d\n", scalar @packages;
printf "  Listed and installed: %d\n", scalar @installed_and_listed;
printf "  Listed but not installed: %d\n", scalar @listed_not_installed;
printf "  Installed but not listed: %d\n", scalar @installed_not_listed;
