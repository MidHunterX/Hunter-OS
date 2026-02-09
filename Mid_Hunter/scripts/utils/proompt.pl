#!/usr/bin/perl
use strict;
use warnings;

# -----------------------------------------------------------------------------
# PROOMPT.pl - Sync code blocks in Markdown with actual file contents
# Usage: perl PROOMPT.pl [input_file]
# -----------------------------------------------------------------------------
my $input_file = shift || 'PROOMPT.md';

# -----------------------------------------------------------------------------
# File extension to language hashmap for Markdown code fences
# -----------------------------------------------------------------------------
my %LANGUAGE_MAP = (
	'adoc' => 'asciidoc',
	'py'   => 'python',
	'sh'   => 'bash',
	'pl'   => 'perl',
	'rb'   => 'ruby',
	'js'   => 'javascript',
	'ts'   => 'typescript',
	'cc'   => 'cpp',
	'h'    => 'c',
	'hpp'  => 'cpp',
	'rs'   => 'rust',
	'yml'  => 'yaml',
	'md'   => 'markdown',
	'txt'  => '',
);

# -----------------------------------------------------------------------------
# █░█ ▀█▀ █ █░░ █ ▀█▀ █▄█   █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
# █▄█ ░█░ █ █▄▄ █ ░█░ ░█░   █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█
# -----------------------------------------------------------------------------

# Reads an entire file into an array
sub read_file_lines {
	my ($path) = @_;
	open my $file_handle, '<', $path or die "ERROR: Cannot open $path: $!";
	my @lines = <$file_handle>;
	close $file_handle;
	return @lines;
}

sub write_file_lines {
	my ($path, $lines_ref) = @_;
	open my $file_handle, '>', $path or die "ERROR: Cannot write $path: $!";
	print $file_handle @$lines_ref;
	close $file_handle;
}

sub detect_language {
	my ($filename) = @_;
	if ($filename =~ /\.([^.\/]+)$/) {
		my $ext = $1;
		return $LANGUAGE_MAP{$ext} // $ext;
	}
	return '';
}

sub clean_backtick_lines {
	my @lines = @_;
	return grep { $_ !~ /```/ } @lines;
}

sub get_file_content {
	my ($path) = @_;
	open my $fh, '<', $path or return "(WARNING: Could not read $path)\n";
	my @lines = <$fh>;
	close $fh;
	@lines = clean_backtick_lines(@lines);
	return @lines;
}

sub delete_existing_block {
	my ($lines_ref, $i_ref, $out_ref) = @_;
	my $i = $$i_ref;
	return unless defined $lines_ref->[$i];
	if ($lines_ref->[$i] =~ /^```/) {
		$i++;
		while ($i < @$lines_ref && $lines_ref->[$i] !~ /^```/) {
			$i++;
		}
		$i++ if $i < @$lines_ref && $lines_ref->[$i] =~ /^```/;
	}
	$$i_ref = $i;
}

# -----------------------------------------------------------------------------
# █▀▀ █▀█ █▀█ █▀▀   █░░ █▀█ █▀▀ █ █▀▀
# █▄▄ █▄█ █▀▄ ██▄   █▄▄ █▄█ █▄█ █ █▄▄
# -----------------------------------------------------------------------------

sub process_markdown {
	my @lines = @_;
	my @out;
	my $i = 0;

	while ($i < @lines) {
		chomp(my $line = $lines[$i]);

		# probable file path
		if ($line =~ m{^[\w./()@+\[\]-]+\.[\w]+$} && -f $line) {
			my $path = $line;
			my $lang = detect_language($path);

			push @out, "$path\n";
			$i++;

			# Skip possible blank line or code fence one line below
			my $j = $i;
			while ($j < @lines && $lines[$j] =~ /^\s*$/) { $j++; }  # skip empty lines
			if ($j < @lines && $lines[$j] =~ /^```/) { $i = $j; } # start delete from fence line

			delete_existing_block(\@lines, \$i, \@out);

			# Insert updated block
			push @out, "\n";
			push @out, "```$lang\n";
			push @out, get_file_content($path);
			push @out, "```\n";
		} else {
			push @out, "$line\n";
			$i++;
		}
	}
	return @out;
}

# -----------------------------------------------------------------------------
# █▀▄▀█ ▄▀█ █ █▄░█
# █░▀░█ █▀█ █ █░▀█
# -----------------------------------------------------------------------------

sub main {
	my @input_lines = read_file_lines($input_file);
	my @updated = process_markdown(@input_lines);
	write_file_lines($input_file, \@updated);
	print "Updated fenced code blocks in $input_file\n";
}

main();
