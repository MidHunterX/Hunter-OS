use strict;
use warnings;
use Test::More;
use FindBin;
use lib ".";

# 1. Test Module Loading
BEGIN { use_ok('Logic', qw(analyze_state get_window_type)) }

# Mock Configuration Data (No files needed for testing!)
my $mock_config = {
    types => {
        "null" => "desktop",
        "firefox" => "browser",
        "kitty"   => "terminal"
    },
    actions => {
        "browser" => {
            "entertainment" => ["youtube", "reddit"],
            "research"      => ["wiki"]
        },
        "terminal" => {
            "coding" => [".pl", "nvim"]
        }
    },
    contents => {
        "perl"    => [".pl"],
        "YouTube" => ["youtube"]
    }
};

subtest 'Window Type Detection' => sub {
    is(Logic::get_window_type("firefox", $mock_config->{types}), "browser", "Identifies firefox");
    is(Logic::get_window_type("UnknownApp", $mock_config->{types}), "unknown", "Handles unknown apps");
    is(Logic::get_window_type(undef, $mock_config->{types}), "desktop", "Handles null/undef as desktop");
};

subtest 'Full Analysis Logic - Browser/YouTube' => sub {
    my $win = {
        class => "firefox",
        title => "Cat Videos - YouTube"
    };

    my $res = analyze_state($win, $mock_config);

    is($res->{wintype}, "browser", "Type is browser");
    is($res->{action}, "entertainment", "Action is entertainment (from youtube keyword)");
    is($res->{content}, "YouTube", "Content is YouTube");
};

subtest 'Full Analysis Logic - Terminal/Coding' => sub {
    my $win = {
        class => "kitty",
        title => "nvim awareness.pl"
    };

    my $res = analyze_state($win, $mock_config);

    is($res->{wintype}, "terminal", "Type is terminal");
    is($res->{action}, "coding", "Action is coding (from .pl keyword)");
    is($res->{content}, "perl", "Content is perl");
};

subtest 'Edge Cases' => sub {
    my $win = { class => "null", title => "" };
    my $res = analyze_state($win, $mock_config);

    is($res->{wintype}, "desktop", "Undefined class defaults to desktop");
    is($res->{action}, "something", "No keywords results in 'something'");
    is($res->{content}, "something", "No keywords results in 'something'");
};

done_testing();
