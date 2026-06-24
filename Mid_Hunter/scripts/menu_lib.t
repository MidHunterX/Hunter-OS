#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Test::More tests => 5;
use File::Temp qw(tempfile tempdir);
use File::Basename;
use File::Spec;
use Encode qw(encode_utf8);

# Prevent "Wide character in print" warnings from Test::More outputting emojis/nerdfonts
use open ':std', ':encoding(UTF-8)';

use lib dirname(File::Spec->rel2abs($0));
use MenuLib qw(
    parse_emojis
    parse_nerdfonts
    get_switch_entries
    bump_to_top
);

# Test emoji JSON parsing
# decode_json expects raw bytes, but `use utf8;` makes our string wide characters.
# So we encode it to raw bytes first just like HTTP::Tiny would return.
my $fake_emoji_json = '{"😀": ["grinning", "face", "smile_face"]}';
my $emoji_out = parse_emojis(encode_utf8($fake_emoji_json));
is($emoji_out, "😀 grinning face smile face\n", "Parsed Emoji JSON correctly, subbed underscores");

# Test nerdfonts CSS parsing
my $fake_css = <<'CSS';
.nf-custom-c:before {
  content: "\e600";
}
CSS
my $nf_out = parse_nerdfonts($fake_css);
my $expected_char = chr(0xe600);
is($nf_out, "$expected_char custom-c\n", "Parsed Nerdfont CSS into character/class pairs");

# Test switch entries mapping (Emoji Menu filter)
my @entries = get_switch_entries("Emoji Menu");
is_deeply(\@entries, ["Font Menu"], "Filtered switch entries correctly for Emoji Menu");

# Test switch entries mapping (Font Menu filter)
@entries = get_switch_entries("Font Menu");
is_deeply(\@entries, ["Emoji Menu"], "Filtered switch entries correctly for Font Menu");

# Test bump_to_top file re-arranging
my ($fh, $filename) = tempfile();
binmode($fh, ":encoding(UTF-8)");
print $fh "line 1\nline 2\nline 3\n";
close $fh;

bump_to_top("line 2", $filename);
open my $in, '<:encoding(UTF-8)', $filename or die;
my @lines = <$in>;
close $in;

is_deeply(\@lines, ["line 2\n", "line 1\n", "line 3\n"], "bump_to_top successfully moves item to the top");
