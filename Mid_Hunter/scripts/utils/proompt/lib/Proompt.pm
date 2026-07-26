package Proompt;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    process_markdown
    detect_language
    clean_backtick_lines
    get_file_content
);

# =============================================================================
# Constants & Configuration
# =============================================================================

use constant LANGUAGE_MAP => {
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
};

use constant EXTENSION_RE   => qr/\.([^.\/]+)$/;
use constant FILE_INC_RE    => qr{^ ( [\w./()@+\[\]-]+\.\w+ ) (?: :(\d+) :(\d+) )? $}x;
use constant CODE_TAG_RE    => qr{<code> (.*?) </code>}xi;
use constant CODE_FENCE_RE  => qr/^```/;
use constant BLANK_LINE_RE  => qr/^\s*$/;

# =============================================================================
# Exported Public API
# =============================================================================

sub detect_language {
    my ($filename) = @_;
    return '' unless defined $filename && $filename =~ EXTENSION_RE;

    my $ext = $1;
    my $map = LANGUAGE_MAP;
    return exists $map->{$ext} ? $map->{$ext} : $ext;
}

sub clean_backtick_lines {
    my (@lines) = @_;
    return grep { $_ !~ CODE_FENCE_RE } @lines;
}

sub get_file_content {
    my ($path, $start_line, $end_line) = @_;

    my @lines = _read_file_lines($path);

    if (defined $start_line && defined $end_line) {
        @lines = _slice_line_range(\@lines, $start_line, $end_line);
    }

    return clean_backtick_lines(@lines);
}

sub process_markdown {
    my (@lines) = @_;
    my @output;
    my $i = 0;

    while ($i < @lines) {
        my $line = $lines[$i];
        chomp(my $trimmed = $line);

        if (my $inc = _parse_file_inclusion($trimmed)) {
            push @output, $line;
            $i = _skip_existing_code_block(\@lines, $i + 1);
            push @output, _format_file_block($inc->{path}, $inc->{start}, $inc->{end});
        }
        elsif (my $cmd = _parse_code_tag($trimmed)) {
            push @output, $line;
            $i = _skip_existing_code_block(\@lines, $i + 1);
            push @output, _format_command_block($cmd);
        }
        else {
            push @output, $line;
            $i++;
        }
    }

    return @output;
}

# =============================================================================
# Internal Helpers
# =============================================================================

sub _read_file_lines {
    my ($path) = @_;
    open my $fh, '<', $path or return ("(WARNING: Could not read $path)\n");
    my @lines = <$fh>;
    close $fh;
    return @lines;
}

sub _slice_line_range {
    my ($lines_ref, $start_line, $end_line) = @_;
    my $total_lines = @$lines_ref;

    $start_line = 1            if $start_line < 1;
    $end_line   = $total_lines if $end_line > $total_lines;

    if ($start_line <= $end_line && $start_line <= $total_lines) {
        return @{$lines_ref}[ $start_line - 1 .. $end_line - 1 ];
    }

    return ();
}

sub _parse_file_inclusion {
    my ($text) = @_;
    if ($text =~ FILE_INC_RE) {
        my ($path, $start, $end) = ($1, $2, $3);
        return { path => $path, start => $start, end => $end } if -f $path;
    }
    return;
}

sub _parse_code_tag {
    my ($text) = @_;
    if ($text =~ CODE_TAG_RE) {
        return $1;
    }
    return;
}

sub _format_file_block {
    my ($path, $start_line, $end_line) = @_;
    my $lang = detect_language($path);

    return (
        "```$lang\n",
        get_file_content($path, $start_line, $end_line),
        "```\n",
    );
}

sub _format_command_block {
    my ($command) = @_;
    $command =~ s/^\s+|\s+$//g;

    my $cmd_output = `$command`;
    my @block = ("```\n");

    if (defined $cmd_output && length $cmd_output) {
        push @block, $cmd_output;
        push @block, "\n" unless $cmd_output =~ /\n$/;
    }

    push @block, "```\n";
    return @block;
}

sub _skip_existing_code_block {
    my ($lines_ref, $index) = @_;
    my $curr = $index;

    # Skip optional blank lines preceding a code block
    $curr++ while $curr < @$lines_ref && $lines_ref->[$curr] =~ BLANK_LINE_RE;

    # Check if an existing code block fence starts here
    if ($curr < @$lines_ref && $lines_ref->[$curr] =~ CODE_FENCE_RE) {
        $curr++; # Skip opening fence line
        $curr++ while $curr < @$lines_ref && $lines_ref->[$curr] !~ CODE_FENCE_RE; # Skip block body
        $curr++ if $curr < @$lines_ref && $lines_ref->[$curr] =~ CODE_FENCE_RE;    # Skip closing fence line
        return $curr;
    }

    # If no code block fence was found, return original index to preserve whitespace
    return $index;
}

1;
