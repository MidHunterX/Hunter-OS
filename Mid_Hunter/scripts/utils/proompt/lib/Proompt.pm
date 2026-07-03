package Proompt;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(process_markdown detect_language clean_backtick_lines get_file_content);

# -----------------------------------------------------------------------------
# Configuration
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
    # Remove lines containing triple backticks to prevent markdown nesting errors
    return grep { $_ !~ /```/ } @lines;
}

sub get_file_content {
    my ($path, $start_line, $end_line) = @_;

    if (open my $fh, '<', $path) {
        my @lines = <$fh>;
        close $fh;

        # If line numbers are given, filter the array (converting 1-based line nums to 0-based index)
        if (defined $start_line && defined $end_line) {
            $start_line = 1 if $start_line < 1;
            $end_line = @lines if $end_line > @lines;

            if ($start_line <= $end_line && $start_line <= @lines) {
                @lines = @lines[$start_line - 1 .. $end_line - 1];
            } else {
                @lines = (); # Invalid range returns empty
            }
        }

        return clean_backtick_lines(@lines);
    }
    return "(WARNING: Could not read $path)\n";
}

sub delete_existing_block {
    my ($lines_ref, $i_ref) = @_;
    my $i = $$i_ref;
    my $start_i = $i;

    # If the next non-empty line starts a code block, skip until the end of that block
    while ($i < @$lines_ref && $lines_ref->[$i] =~ /^\s*$/) {
        $i++;
    }

    if ($i < @$lines_ref && $lines_ref->[$i] =~ /^```/) {
        $i++; # skip opening fence
        while ($i < @$lines_ref && $lines_ref->[$i] !~ /^```/) {
            $i++;
        }
        if ($i < @$lines_ref && $lines_ref->[$i] =~ /^```/) {
            $i++; # skip closing fence
        }
        $$i_ref = $i;
    } else {
        # If no code block is found, revert so we don't accidentally consume intentional empty lines
        $$i_ref = $start_i;
    }
}

sub process_markdown {
    my (@lines) = @_;
    my @out;
    my $i = 0;

    while ($i < @lines) {
        my $line = $lines[$i];
        chomp(my $trimmed = $line);

        # Check if line matches a file path (optionally ending with :start:end)
        if ($trimmed =~ m{^([\w./()@+\[\]-]+\.\w+)(?::(\d+):(\d+))?$} && -f $1) {
            my $path = $1;
            my $start_line = $2;
            my $end_line = $3;
            my $lang = detect_language($path);

            push @out, "$line";
            $i++;

            # Move pointer forward to skip any existing code block below it
            delete_existing_block(\@lines, \$i);

            # Insert updated code fence block
            push @out, "```$lang\n";
            push @out, get_file_content($path, $start_line, $end_line);
            push @out, "```\n";
        }
        # Check if line matches a <code> execution tag
        elsif ($trimmed =~ m{<code>(.*?)</code>}i) {
            my $command = $1;
            $command =~ s/^\s+//;
            $command =~ s/\s+$//;

            push @out, "$line";
            $i++;

            # Move pointer forward to skip any existing code block below it
            delete_existing_block(\@lines, \$i);

            # Execute command and capture output
            my $output = `$command`;

            push @out, "```\n";
            if (defined $output && length $output > 0) {
                push @out, $output;
                push @out, "\n" unless $output =~ /\n$/;
            }
            push @out, "```\n";
        }
        else {
            push @out, $line;
            $i++;
        }
    }
    return @out;
}

1;
