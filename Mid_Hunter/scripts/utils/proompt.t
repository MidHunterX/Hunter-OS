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
    my @input = ("Hello\n", "```\n", "World\n");
    my @cleaned = Proompt::clean_backtick_lines(@input);
    is(scalar @cleaned, 2, 'Removes lines with backticks');
    ok(!grep(/```/, @cleaned), 'No backticks remain');
};

subtest 'File Content Retrieval' => sub {
    my ($fh, $filename) = tempfile();
    print $fh "line 1\n```\nline 2";
    close $fh;

    my @content = Proompt::get_file_content($filename);
    is_deeply(\@content, ["line 1\n", "line 2"], 'Reads file and strips backticks');
    unlink $filename;
};

subtest 'Markdown Processing: Fresh Insertion' => sub {
    # Create a dummy file to be "synced"
    my ($fh, $src_file) = tempfile(SUFFIX => '.py');
    print $fh "print('hello')";
    close $fh;

    my @input = ("Check this file:\n", "$src_file\n", "End of doc\n");
    my @output = Proompt::process_markdown(@input);

    my $out_str = join('', @output);
    like($out_str, qr/```python/, 'Inserted code fence with correct language');
    like($out_str, qr/print\('hello'\)/, 'Inserted correct file content');

    unlink $src_file;
};

subtest 'Markdown Processing: Existing Block Replacement' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.sh');
    print $fh "echo hi";
    close $fh;

    my @input = (
        "$src_file\n",
        "```bash\n",
        "OLD CONTENT\n",
        "```\n",
        "Footer\n"
    );
    my @output = Proompt::process_markdown(@input);
    my $out_str = join('', @output);

    unlike($out_str, qr/OLD CONTENT/, 'Old content was removed');
    like($out_str, qr/echo hi/, 'New content was inserted');
    is(($out_str =~ s/```//g), 2, 'Still only has one code block (2 fences)');

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
    like(join('', @output), qr/```\n```/, 'Handles empty files gracefully');

    unlink $src_file;
};

subtest 'Edge Case: Path with dots' => sub {
    my ($fh, $src_file) = tempfile('./test.file.XXXX', SUFFIX => '.js');
    print $fh "console.log()";
    close $fh;

    my @output = Proompt::process_markdown("$src_file\n");
    like(join('', @output), qr/```javascript/, 'Handles files with multiple dots');

    unlink $src_file;
};

subtest 'Edge Case: Whitespace between Path and Fence' => sub {
    my ($fh, $src_file) = tempfile(SUFFIX => '.pl');
    print $fh "exit;";
    close $fh;

    my @input = ("$src_file\n", "\n", "\n", "```perl\n", "old\n", "```\n");
    my @output = Proompt::process_markdown(@input);

    # It should collapse the space and replace the block
    my $out_str = join('', @output);
    unlike($out_str, qr/old/, 'Replaces block even with intervening whitespace');

    unlink $src_file;
};

done_testing();
