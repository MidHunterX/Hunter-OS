#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8"); # Fixes "Wide character in print"
use JSON::PP;
use File::Basename;
use Cwd 'abs_path';
use Term::ANSIColor qw(:constants);

# Failsafe mechanism for relative links
my $script_dir = dirname(abs_path($0));
chdir($script_dir) or die "Could not change directory to $script_dir: $!";

# Load JSON Data
sub load_json {
    my ($filename) = @_;
    open my $fh, '<', "data/$filename" or die "Could not open data/$filename: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    return decode_json($content);
}


my $prev_window = "";

sub get_active_window {
    my $json_raw = `hyprctl activewindow -j`;
    return undef if !$json_raw;
    return decode_json($json_raw);
}

# WindowClass -> WindowType
my $window_types = load_json("window_types.json");
sub get_window_type {
    my ($class) = @_;
    $class = lc($class // "null");
    return $window_types->{$class} // "nothing";
}

# WindowType -> UserAction
my $user_actions = load_json("user_actions.json");
sub get_inferred_action {
    my ($wintype, $title) = @_;
    $title = lc($title // "");
    my $actions = $user_actions->{$wintype} // {};
    foreach my $action_name (keys %$actions) {
        my $keywords = $actions->{$action_name};
        foreach my $keyword (@$keywords) {
            if ($title =~ m{\Q$keyword\E}) {
                return $action_name;
            }
        }
    }
    return "nothing";
}

# WindowTitle -> WindowContent
my $window_contents = load_json("window_contents.json");
sub get_possible_content {
    my ($title) = @_;
    $title = lc($title // "");
    foreach my $content_type (keys %$window_contents) {
        my $keywords = $window_contents->{$content_type};
        foreach my $keyword (@$keywords) {
            if (index($title, lc($keyword)) != -1) {
                return $content_type;
            }
        }
    }
    return "something";
}

# Main Loop
while (1) {
    my $win = get_active_window();

    if ($win && $win->{title} ne $prev_window) {
        my $class = $win->{class} || "null";
        my $title = $win->{title} || "";

        my $wintype = get_window_type($class);
        my $action  = get_inferred_action($wintype, $title);
        my $content = get_possible_content($title);

        # Test Logs
        my $msg = "Doing $action on $wintype with $content";
        system("notify-send", "-t", "3000", $class, $msg);
        print "{\n";
        print "  ".RED."title: ".RESET."$title\n";
        print "  ".RED."class: ".RESET."$class\n";
        print "  ".RED."inference: ".RESET."{";
        print " ".GREEN."wintype: ".RESET."$wintype".",";
        print " ".GREEN."content: ".RESET."$content".",";
        print " ".GREEN."action: ".RESET."$action"." }\n";
        print "  ".RED."msg: ".RESET."$msg\n";
        print "}\n";

        $prev_window = $title;
    }

    sleep 5;
}
