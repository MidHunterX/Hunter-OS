#!/usr/bin/env perl
use POSIX;
use Term::ANSIColor qw(:constants);
use Sys::Hostname qw(hostname);

# ============================== CONFIGURATION ============================== #

# my $ICO = '  ';   # Classic Dots
# my $ICO = '🯇🯅🯈 ';  # Groupism
# my $ICO = '⣿⣿⣿ ';  # Air Vent
# my $ICO = '▜██▙';  # Egyptian Snek
# my $ICO = '██';  # Sharp Edges
# my $ICO = '';  # Stripes (Left-Right)
my $ICO = '';  # Stripes (Right-Left)
# my $ICO = '';  # Tigerstripes
my $BAR_SIZE = 25;

# ================================ UTILITIES ================================ #

# Inspiration from GNU
sub cat {
    my ($file) = @_;
    open(my $fh, '<', "$file") or return "N/A";
    my $content = <$fh>;
    chomp $content;
    close($fh);
    return $content;
}

# Inspiration from HTML5
sub progress {
    my %args = (
        value => 0,
        max => 100,
        bar_size => 30,
        char_fill => "🬋",
        char_empty => "🬋",
        @_, # Override Defaults
    );

    my $ratio = $args{value} / $args{max};
    $ratio = 0 if $ratio < 0;
    $ratio = 1 if $ratio > 1;
    my $filled = ceil($ratio * $args{bar_size});
    my $empty  = $args{bar_size} - $filled;
    return MAGENTA . $args{char_fill} x $filled . BRIGHT_MAGENTA . $args{char_empty} x $empty . RESET;
}

# ============================= DATA COLLECTION ============================= #

# Battery
my $battery_capacity = cat("/sys/class/power_supply/BAT0/capacity");
my $battery_bar = progress(value => $battery_capacity);

# OS Name
my $os_name = "Linux";
if (open my $fh, '<', '/etc/os-release') {
    while (<$fh>) {
        if (/^PRETTY_NAME=(.*)/) {
            $os_name = $1;
            $os_name =~ s/^"|"$//g;   # strip quotes
            last;
        }
    }
}

# CPU Name
my $cpu_info = "Unknown CPU";
if (open(my $fh, '<', '/proc/cpuinfo')) {
    while (<$fh>) {
        if (/^model name\s+:\s+(.*)$/) {
            $cpu_info = $1;
            $cpu_info =~ s/\(R\)|\(TM\)|Processor|CPU//g; # Clean up
            $cpu_info =~ s/\s+/ /g;
            last;
        }
    }
    close($fh);
}

# GPU Name
my $gpu_info = `lspci | grep -Ei 'vga|3d|display' | cut -d':' -f3`;
$gpu_info =~ s/\[.*?\]//g; # Remove hex IDs
$gpu_info =~ s/Corporation|Integrated Graphics Controller//gi;
$gpu_info =~ s/^\s+|\s+$//g;
$gpu_info ||= "Unknown GPU";

# Host Device
my $prod = cat("/sys/devices/virtual/dmi/id/product_name");
my $vers = cat("/sys/devices/virtual/dmi/id/product_version");
my $host_device = "$prod $vers";

# Uptime
my $uptime_raw = `uptime -p`;
$uptime_raw =~ s/up //;
my @parts = split(/,\s*|\s+/, $uptime_raw);
my $uptime_formatted = "";
for (my $i=0; $i < @parts; $i+=2) {
    $uptime_formatted .= MAGENTA . "$parts[$i]" . RESET . " $parts[$i+1] " if $parts[$i+1];
}

# SSD Usage (adjust device path if necessary)
my $df_out = `df -h /dev/nvme0n1p5 | awk 'NR==2 {print \$5}'`;
$df_out =~ s/%//g;
my $ssd_percent = int($df_out || 0);
my $ssd_col = $ssd_percent > 90 ? RED : ($ssd_percent > 80 ? YELLOW : WHITE);

# RAM
my $free_mem = `free -m | grep Mem:`;
my (undef, $ram_total, $ram_used) = split(/\s+/, $free_mem);
my $ram_percent = int(($ram_used / $ram_total) * 100);
my $ram_display = $ram_used > 1024 ? sprintf("%.1f GB", $ram_used/1024) : "$ram_used MB";
my $ram_col = $ram_percent > 80 ? RED : ($ram_percent > 50 ? YELLOW : WHITE);

# SWAP
my $free_swp = `free -m | grep Swap:`;
my (undef, $swp_total, $swp_used) = split(/\s+/, $free_swp);
my $swp_percent = $swp_total > 0 ? int(($swp_used / $swp_total) * 100) : 0;
my $swp_col = $swp_percent > 80 ? RED : ($swp_percent > 50 ? YELLOW : WHITE);

# Battery
my $bat_percent = cat("/sys/class/power_supply/BAT0/capacity") || 0;
my $bat_status = cat("/sys/class/power_supply/BAT0/status") || "";
my $bat_now = cat("/sys/class/power_supply/BAT0/power_now") || 0;
my $bat_watt = sprintf("%.1f", $bat_now / 1000000);
my $bat_ico = $bat_status eq 'Charging' ? YELLOW."󱐋".RESET : "";
my $bat_col = $bat_percent > 60 ? WHITE : ($bat_percent > 30 ? YELLOW : RED);
my $bat_val = $bat_watt ne "0.0" ? "${bat_percent}% \@${bat_watt}W" : "${bat_percent}%";

# ================================= LAYOUT ================================= #

my $R   = RESET;
my $U   = UNDERLINE;
my $X   = BLUE;     # Accent 1
my $Y   = YELLOW;   # Accent 2
my $H   = BLUE;     # Heading
my $B   = GREEN;    # Bold
my $V   = BOLD . MAGENTA;  # Values

my $user = $ENV{USER} // getpwuid($<);
my $host = hostname();
my $user_host = "$H$user".WHITE."\@$H$host$R";
my $date_str = `date +"$V%d$R %b %Y, $V%H:%M$R %a"`; chomp $date_str;
my $color_str = RED.$ICO . GREEN.$ICO . YELLOW.$ICO . BLUE.$ICO . MAGENTA.$ICO . CYAN.$ICO . WHITE.$ICO . BLACK.$ICO . RESET;

print "\n";
printf "  %s     %s     %s        %s%s%s%s%s%s%s%s%s\n", $X, $Y."o.", "   .o", $color_str;
print  "  ${X},    ${Y}yyo${X}      ${Y}oyy${X}    ,${R}\n";
print  "  ${X}oNo  ${Y}yyy${X}      ${Y}yyy${X}  oNo${R}   ${U}${user_host}${R}\n";
print  "  ${X}oMMNs${Y}yyy${X}      ${Y}yyy${X}sNMMo${R}   ${B}OS:${R} $os_name\n";
print  "  ${X}oMMMM${Y}yyy${X}      ${Y}yyy${X}MMMMo${R}   ${B}Device:${R} $host_device\n";
print  "  ${X}oMMhd${Y}yyy${X}y.  .y${Y}yyy${X}yyMMo${R}   ${B}Datetime:${R} $date_str\n";
print  "  ${X}oMMo ${Y}yyy${X}MMyyMM${Y}yyy${X} oMMo${R}   ${B}Uptime:${R} $uptime_formatted\n";
print  "  ${X}oMMo ${Y}yyy${X}sNMMNo${Y}yyy${X} oMMo${R}\n";
print  "  ${X}oMMo ${Y}yyy${X} '++' ${Y}yyy${X} oMMo${R}   ${U}${H}Device Details:${R}\n";
print  "  ${X}oMMo ${Y}yyy${X}      ${Y}yyy${X} oMMo${R}   ${B}CPU:${R} $cpu_info\n";
print  "  ${X}oMMo ${Y}oyy${X}      ${Y}yyo${X} oMMo${R}   ${B}GPU:${R} $gpu_info\n";
print  "  ${X}oMMo ${Y} *o${X}      ${Y}o* ${X} oMMo${R}   ${B}SSD:${R} " . progress(value => $ssd_percent, bar_size => $BAR_SIZE) . " $ssd_col$ssd_percent%$R\n";
print  "  ${X}oMMo ${Y}   ${X}      ${Y}   ${X} oMMo${R}   ${B}RAM:${R} " . progress(value => $ram_percent, bar_size => $BAR_SIZE) . " $ram_col$ram_display$R\n";
print  "  ${X}:NMo ${Y}   ${X}      ${Y}   ${X} oMN:${R}   ${B}SWP:${R} " . progress(value => $swp_percent, bar_size => $BAR_SIZE) . " $swp_col$swp_used MB$R\n";
print  "  ${X}  o+ ${Y}   ${X}      ${Y}   ${X} +o  ${R}   ${B}BAT:${R} " . progress(value => $bat_percent, bar_size => $BAR_SIZE) . " $bat_col$bat_val$R $bat_ico\n";
