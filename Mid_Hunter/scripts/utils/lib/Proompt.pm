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
    my ($path) = @_;
    if (open my $fh, '<', $path) {
        my @lines = <$fh>;
        close $fh;
        return clean_backtick_lines(@lines);
    }
    return "(WARNING: Could not read $path)\n";
}

sub delete_existing_block {
    my ($lines_ref, $i_ref) = @_;
    my $i = $$i_ref;

    # If the next non-empty line starts a code block, skip until the end of that block
    while ($i < @$lines_ref && $lines_ref->[$i] =~ /^\s*$/) {
        $i++;
    }

    if ($i < @$lines_ref && $lines_ref->[$i] =~ /^```/) {
        $i++; # skip opening fence
        while ($i < @$lines_ref && $lines_ref->[$i] !~ /^```/) {
            $i++;
        }
        $i++ if $i < @$lines_ref && $lines_ref->[$i] =~ /^```/; # skip closing fence
    }
    $$i_ref = $i;
}

sub process_markdown {
    my (@lines) = @_;
    my @out;
    my $i = 0;

    while ($i < @lines) {
        my $line = $lines[$i];
        chomp(my $trimmed = $line);

        # Check if line looks like a file path and exists on disk
        if ($trimmed =~ m{^[\w./()@+\[\]-]+\.[\w]+$} && -f $trimmed) {
            my $path = $trimmed;
            my $lang = detect_language($path);

            push @out, "$path\n";
            $i++;

            # Move pointer forward to skip any existing code block
            delete_existing_block(\@lines, \$i);

            # Insert updated block
            push @out, "\n";
            push @out, "```$lang\n";
            push @out, get_file_content($path);
            push @out, "```\n";
        } else {
            push @out, $line;
            $i++;
        }
    }
    return @out;
}

1;
