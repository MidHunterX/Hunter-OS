use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile);
use File::Basename;
use lib 'lib';

use_ok('Proompt', qw(process_markdown detect_language clean_backtick_lines get_file_content));

subtest 'Language Detection' => sub {
    is(Proompt::detect_language('test.py'), 'python', 'Recognizes python');
    is(Proompt::detect_language('script.pl'), 'perl', 'Recognizes perl');
    is(Proompt::detect_language('styles.css'), 'css', 'Handles unknown in map by returning extension');
    is(Proompt::detect_language('README'), '', 'Handles no extension');
};

subtest 'Backtick Cleaning' => sub {
    my @input = ("line 1\n", "```python\n", "line 2\n", "```\n");
    my @cleaned = Proompt::clean_backtick_lines(@input);
    is(scalar @cleaned, 2, 'Removes lines with backticks');
};

subtest 'File Content Retrieval' => sub {
    my ($fh, $filename) = tempfile();
    print $fh "line 1\n```\nline 2\n```\n";
    close $fh;

    my @content = Proompt::get_file_content($filename);
    is_deeply(\@content, ["line 1\n", "line 2\n"], 'Reads file and strips backticks');
    unlink $filename;
};


subtest 'Malformed File Content Retrieval' => sub {
    my ($fh, $filename) = tempfile();
    print $fh "line 1\n```\nline 2\n";
    close $fh;

    my @content = Proompt::get_file_content($filename);
    is_deeply(\@content, ["line 1\n", "line 2\n"], 'Reads file and strips backticks');
    unlink $filename;
};

subtest 'Line Range Extraction' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.txt');
    print $fh "L1\nL2\nL3\nL4\nL5\n";
    close $fh;

    my @input = ("$src_file:2:4\n");
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    like($out_str, qr/L2\nL3\nL4\n/, 'Extracts only specified lines');
    unlike($out_str, qr/L1/, 'Excludes line before range');
    unlike($out_str, qr/L5/, 'Excludes line after range');

    unlink $src_file;
};

subtest 'Markdown Processing: Fresh Insertion' => sub {
    # Create a dummy file to be "synced"
    my ($fh, $src_file) = tempfile(SUFFIX => '.py');
    print $fh "print('hello')\n";
    close $fh;

    my @input = ("Check this file:\n", "$src_file\n", "End of doc\n");
    my @output = Proompt::process_markdown(@input);

    my $out_str = join('', @output);
    like($out_str, qr/print\('hello'\)/, 'Inserted correct file content');

    unlink $src_file;
};

subtest 'Markdown Processing: Existing Block Replacement' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.sh');
    print $fh "echo hi\n";
    close $fh;

    my @input = (
        "$src_file\n",
        "```sh\n",
        "OLD CONTENT\n",
        "```\n",
        "Footer\n"
    );
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    unlike($out_str, qr/OLD CONTENT/, 'Old content was removed');
    like($out_str, qr/echo hi/, 'New content was inserted');

    unlink $src_file;
};

subtest 'Edge Case: Missing Files' => sub {
    my @input = ("non_existent_file.txt\n");
    my @output = Proompt::process_markdown(@input);
    is_deeply(\@input, \@output, 'Ignore filenames that do not exist on disk');
};

subtest 'Edge Case: Empty File' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.txt');
    close $fh; # Empty

    my @input = ("$src_file\n");
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    like($out_str, qr/```\s*```/, 'Empty file generates empty code block properly');

    unlink $src_file;
};

subtest 'Edge Case: Path with dots' => sub {
    my ($fh, $src_file) = tempfile('./test.file.XXXX', SUFFIX => '.js');
    print $fh "console.log()\n";
    close $fh;

    my @output = Proompt::process_markdown("$src_file\n");
    my $out_str = join('', @output);
    like($out_str, qr/console\.log\(\)/, 'Understands file names with variable dot placement');

    unlink $src_file;
};

subtest 'Edge Case: Whitespace between Path and Fence' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.pl');
    print $fh "exit;\n";
    close $fh;

    my @input = (
        "$src_file\n",
        "\n",
        "```pl\n",
        "old\n",
        "```\n",
    );
    my @output = Proompt::process_markdown(@input);

    # It should collapse the space and replace the block
    my $out_str = join('', @output);
    unlike($out_str, qr/old/, 'Replaces block even with intervening whitespace');
    like($out_str, qr/exit;/, 'Inserts new content');

    unlink $src_file;
};

subtest 'Feature: Code Tag Execution' => sub {
    my @input = ("<code> echo \"Hello, world!\" </code>\n", "Footer\n");
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    like($out_str, qr/Hello, world!/, 'Executes code and includes output');
    like($out_str, qr/```\nHello, world!\n```/, 'Wraps execution output in a code block');
};

subtest 'Feature: Code Tag Replacing Existing Output' => sub {
    my @input = (
        "<code> echo \"New Output\" </code>\n",
        "```\n",
        "Old Output\n",
        "```\n"
    );
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    unlike($out_str, qr/Old Output/, 'Successfully dropped previous code block from markdown');
    like($out_str, qr/New Output/, 'Inserted new code execution trace properly');
};

done_testing();
