#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;

use lib "$FindBin::Bin/.."; # Look one level up for ArchChan.pm
use ArchChan;

my $NODE = "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode";

unless (-e $NODE) {
    animate_message("I'm sorry master, but I couldn't find the battery conservation interface on this hardware.");
    exit 1;
}

# Read current state
open(my $fh, '<', $NODE) or die "Could not open node: $!";
my $current = <$fh>;
chomp($current);
close($fh);

my $status = ($current == 1) ? "*ENABLED* (60% Cap)" : "*DISABLED* (100% Charge)";
my $target_val = ($current == 1) ? 0 : 1;
my $action    = ($current == 1) ? "stop" : "start";
my $tlp_cmd    = ($current == 1) ? "fullcharge" : "setcharge";

animate_message("Current Battery Conservation Mode: $status");

if (animate_prompt("Would you like me to *$action* conservation mode?")) {
    execute_command("sudo tlp $tlp_cmd");
    execute_command("sudo -k");
    animate_message("Settings applied successfully!");
} else {
    animate_message("Understood. I'll leave the power settings as they are.");
}
