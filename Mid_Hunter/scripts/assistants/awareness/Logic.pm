package Logic;

use strict;
use warnings;
use JSON::PP;
use Exporter qw(import);

our @EXPORT_OK = qw(
    load_json
    get_active_window
    get_window_type
    get_inferred_action
    get_possible_content
    analyze_state
);

# Load JSON Data
sub load_json {
    my ($path) = @_;
    open my $fh, '<', $path or die "Could not open $path: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    return decode_json($content);
}

# Wrapper for system call - isolated for easier mocking
sub get_active_window {
    my $json_raw = `hyprctl activewindow -j 2>/dev/null`;
    return undef if !$json_raw || $json_raw =~ /^\s*$/;
    return decode_json($json_raw);
}

# Window.Class -> Window.Type
sub get_window_type {
    my ($class, $window_types) = @_;
    $class = lc($class // "null");
    return $window_types->{$class} // "unknown";
}

# Window.Type -> Window.Type.Action
sub get_inferred_action {
    my ($wintype, $title, $type_actions) = @_;
    $title = lc($title // "");
    my $actions = $type_actions->{$wintype} // {};

    foreach my $action_name (sort keys %$actions) {
        my $keywords = $actions->{$action_name};
        foreach my $keyword (@$keywords) {
            if (index($title, lc($keyword)) != -1) {
                return $action_name;
            }
        }
    }
    return "something";
}

# Window.Title -> Window.Content
sub get_possible_content {
    my ($title, $window_contents) = @_;
    $title = lc($title // "");
    foreach my $content_type (sort keys %$window_contents) {
        my $keywords = $window_contents->{$content_type};
        foreach my $keyword (@$keywords) {
            if (index($title, lc($keyword)) != -1) {
                return $content_type;
            }
        }
    }
    return "something";
}

# The primary "Brain" function that combines everything
sub analyze_state {
    my ($win, $config) = @_;

    my $class = $win->{class} || "null";
    my $title = $win->{title} || "";

    my $wintype = get_window_type($class, $config->{types});
    my $action  = get_inferred_action($wintype, $title, $config->{actions});
    my $content = get_possible_content($title, $config->{contents});

    return {
        class    => $class,
        title    => $title,
        wintype  => $wintype,
        action   => $action,
        content  => $content,
        msg      => "Doing $action on $wintype with $content"
    };
}

1; # Must return a true value
