#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8"); # Fixes "Wide character in print"
use File::Basename;
use Cwd 'abs_path';
use Term::ANSIColor qw(:constants);
use FindBin;
use lib $FindBin::Bin;
use Logic qw(load_json get_active_window analyze_state);

my $script_dir = dirname(abs_path($0));
chdir($script_dir);

# Load configurations
my $config = {
    types    => load_json("data/window_types.json"),
    actions  => load_json("data/type_actions.json"),
    contents => load_json("data/window_contents.json"),
};

my $prev_window = "";

while (1) {
    my $win = get_active_window();

    if ($win && ($win->{title} // "") ne $prev_window) {
        my $res = analyze_state($win, $config);

        # Side Effects
        system("notify-send", "-t", "3000", $res->{class}, $res->{msg});

        print "{\n";
        print "  ".RED."title: ".RESET."$res->{title}\n";
        print "  ".RED."class: ".RESET."$res->{class}\n";
        print "  ".RED."inference: ".RESET."{";
        print " ".GREEN."wintype: ".RESET."$res->{wintype}".",";
        print " ".GREEN."action: ".RESET."$res->{action}".",";
        print " ".YELLOW."content: ".RESET."$res->{content}"." }\n";
        print "  ".RED."msg: ".RESET."$res->{msg}\n";
        print "}\n";

        $prev_window = $res->{title};
    }
    sleep 5;
}
