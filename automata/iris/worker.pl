#!/usr/bin/env perl

# Adaptive Window Contrast based on Wallpaper Brightness
# Requires: ImageMagick, swww (for wallpaper)

use POSIX qw(strftime);
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use File::Basename;

# ============================== CONFIGURATION ============================== #

my $MONITOR            = "eDP-1";
my $AUTOSCALE_STRATEGY = "manual"; # manual | strength | adapt
my $CENTER_BIAS        = 10;      # (0-100)
my $print_logs         = 0;

GetOptions("log" => \$print_logs);

# =========================================================================== #

sub get_timestamp { return strftime("%H:%M:%S", localtime); }

sub log_msg {
    my $msg = shift;
    return unless $print_logs;
    print "[" . GREEN . get_timestamp() . RESET . "] $msg\n";
}

sub error_msg {
    my $msg = shift;
    return unless $print_logs;
    print "[" . RED . get_timestamp() . RESET . "] $msg\n";
}

sub get_swww_wallpaper {
    my $monitor = shift;
    my $cache_file = "$ENV{HOME}/.cache/swww/$monitor";
    return unless -f $cache_file;

    open(my $fh, '<:raw', $cache_file) or return;
    my $content = do { local $/; <$fh> };
    close($fh);

    # The file is null-delimited: [empty][filter][path][...]
    # example: ^@Lanczos3^@/home/user/wall.png^@
    my @parts = split(/\0/, $content);

    # We look for the first part that looks like an absolute path
    foreach my $part (@parts) {
        return $part if $part =~ m{^/};
    }
    return;
}


# INITIALIZE
# -----------------------------------------------------------------------------
my $wallpaper = get_swww_wallpaper($MONITOR);
if (!$wallpaper || ! -f $wallpaper) {
    error_msg("Wallpaper not found or invalid: " . ($wallpaper // "NULL"));
    exit 1;
}
log_msg('Current Wallpaper: '.basename(dirname($wallpaper)).'/'.basename($wallpaper));


# THEME BASED ON WALLPAPER COLOR
# -----------------------------------------------------------------------------
# Fast approximation based on Rec. 601 standard
# usage: hex_brightness("#RRGGBB")
sub hex_brightness {
    my $hex = shift;
    $hex =~ s/^#//; # remove leading `#`
    my $red = hex(substr($hex, 0, 2));
    my $green = hex(substr($hex, 2, 2));
    my $blue = hex(substr($hex, 4, 2));
    # Rec. 601 standard
    return (($red * 299) + ($green * 587) + ($blue * 114)) / 1000;
}

# Convert hex color to ANSI escape sequence
# usage: hex_to_ansi("#RRGGBB", $is_bg)
sub hex_to_ansi {
    my ($hex, $bg) = @_;
    $hex =~ s/^#//;
    my $red = hex(substr($hex, 0, 2));
    my $green = hex(substr($hex, 2, 2));
    my $blue = hex(substr($hex, 4, 2));

    if ($bg) {
        # Set text color contrast (white or black) based on brightness
        my $fg = (hex_brightness($hex) < 128) ? "255;255;255" : "0;0;0";
        return sprintf("\e[38;2;%sm\e[48;2;%d;%d;%dm", $fg, $red, $green, $blue);
    } else {
        return sprintf("\e[38;2;%d;%d;%dm", $red, $green, $blue);
    }
}

my $border = 100 - $CENTER_BIAS;
# Using txt:- with ImageMagick to get the average color without a physical temp file
my $magick_cmd = "magick '$wallpaper' -gravity Center -crop ${border}%x${border}+0+0 -resize 1x1 txt:- 2>/dev/null";
my $magick_out = `$magick_cmd`;

my ($hex_value) = $magick_out =~ /(#[0-9A-F]{6,8})/i;
if (!$hex_value) {
    error_msg("Could not extract color from ImageMagick.");
    exit 1;
}
$hex_value = substr($hex_value, 0, 7); # Standardize to 6 chars

log_msg('Average Color: '.hex_to_ansi($hex_value, 1).' '.$hex_value.' ');

# ACTION: Call Matugen
system("matugen image '$wallpaper' --quiet");
# system("matugen color hex '$hex_value' --quiet");


# THEME BASED ON LIGHT/DARK WALLPAPER
# -----------------------------------------------------------------------------
my $luma_value   = hex_brightness($hex_value);
my $luma_percent = ($luma_value / 255) * 100;

if ($luma_percent > 50) {
    log_msg(sprintf("🌄 Light Wallpaper | (%.1f/255) | %.0f%% Brightness", $luma_value, $luma_percent));
    # system("gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'");
} else {
    log_msg(sprintf("🌃 Dark Wallpaper | (%.1f/255) | %.0f%% Brightness", $luma_value, $luma_percent));
    # system("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'");
}


# AUTOSCALE BRIGHTNESS & CONTRAST
# -----------------------------------------------------------------------------

# Linear Interpolation (lerp)
# Usage: lerp normalized_factor lower_value upper_value
sub lerp {
    my $factor = shift; # normalized factor (0.0–1.0)
    my $dark = shift; # dark / lower value
    my $light = shift; # light / upper value
    return $dark + ($factor * ($light - $dark));
}

sub clamp {
    my ($v, $min, $max) = @_;
    return $min if $v < $min;
    return $max if $v > $max;
    return $v;
}

sub remap_threshold {
    my ($value, $lo, $hi) = @_;
    return 0 if $hi <= $lo; # Avoid division by zero
    my $normalized = ($value - $lo) / ($hi - $lo);
    return clamp($normalized, 0.0, 1.0);
}

my $wallpaper_brightness = $luma_value / 255;

# Thresholds for wallpaper_brightness (Personal Preference)
# NOTE: My most brightest wallpaper sits around at 65% brightness Remapping
# thresholds so that l_values and d_values actually represents window
# preferences for my personal wallpaper collection
my $lo_threshold = 0.0;
my $hi_threshold = 0.7;

$wallpaper_brightness = remap_threshold(
    $wallpaper_brightness,
    $lo_threshold,
    $hi_threshold
);

my ($brightness, $contrast, $vibrancy, $vibrancy_darkness);

if ($AUTOSCALE_STRATEGY eq "manual") {
    # Light Wallpaper (Personal Preference)
    my $l_brightness = 0.35;
    my $l_contrast   = 1.0;
    my $l_vibrancy   = 0.0;
    my $l_vibrancy_darkness = 0.0;

    # Dark Wallpaper (Personal Preference)
    my $d_brightness = 0.6;
    my $d_contrast   = 0.5;
    my $d_vibrancy   = 0.5;
    my $d_vibrancy_darkness = 2.0;

    $brightness = lerp($wallpaper_brightness, $d_brightness, $l_brightness);
    $contrast   = lerp($wallpaper_brightness, $d_contrast, $l_contrast);
    $vibrancy = lerp($wallpaper_brightness, $d_vibrancy, $l_vibrancy);
    $vibrancy_darkness = lerp($wallpaper_brightness, $d_vibrancy_darkness, $l_vibrancy_darkness);
}
elsif ($AUTOSCALE_STRATEGY eq "strength") {
    # wallpaper_brightness (0-1)
    # brightness (0-2) where, 0-1=dark, 1=neutral, 1-2=light
    # contrast (0-2) where, 0-1=dark, 1=neutral, 1-2=light
    my $base_brightness   = 0.5;
    my $base_contrast     = 0.7;
    my $target_brightness = 0.6;
    my $strength          = 0.6;

    my $darkness_factor = 1 - $wallpaper_brightness;
    my $adapt           = $darkness_factor - $target_brightness;

    $brightness = $base_brightness + ($adapt * $strength);
    $contrast   = $base_contrast   + ($adapt * $strength);
}
elsif ($AUTOSCALE_STRATEGY eq "adapt") {
    my $target_brightness = 0.5;  # target percieved brightness of window (0.0 - 2.0)
    # window = 1.2 * t - 0.5 * w # Samey feel
    # window = (t * 1.5) - (w * 0.8) # Higher peaks and lower troughs
    # window = t * (1.1 - (w ^ 2)) # Exponential decay for natural feel
    my $window = $target_brightness * (1.1 - ($wallpaper_brightness ** 2));
    $window = clamp($window, 0.0, 2.0);
    $brightness = $window;
}
else {
    $brightness = 1.0;
    $contrast   = 1.0;
}


# APPLY WINDOW SETTINGS
# -----------------------------------------------------------------------------

my @cmds;
my $r1 = ON_BRIGHT_BLACK;
my $r2 = ON_BLACK;
my $rs = RESET;

log_msg("╭──".BOLD.BLACK.ON_YELLOW." Adaptive Window Settings ".$rs."──┬──────╮");

if (defined $brightness) {
    log_msg($r1.sprintf("│ ☀️ Window Brightness         │ %.2f │", $brightness).$rs);
    push @cmds, "keyword decoration:blur:brightness $brightness";
}

if (defined $contrast) {
    log_msg($r2.sprintf("│ 🌗 Window Contrast           │ %.2f │", $contrast).$rs);
    push @cmds, "keyword decoration:blur:contrast $contrast";
}

if (defined $vibrancy) {
    log_msg($r1.sprintf("│ 🌸 Window Vibrancy           │ %.2f │", $vibrancy).$rs);
    push @cmds, "keyword decoration:blur:vibrancy $vibrancy";
}

if (defined $vibrancy_darkness) {
    log_msg($r2.sprintf("│ 🌸 Window Darkness Vibrancy  │ %.2f │", $vibrancy_darkness).$rs);
    push @cmds, "keyword decoration:blur:vibrancy_darkness $vibrancy_darkness";
}

# https://wiki.hypr.land/Configuring/Using-hyprctl/#batch
system('hyprctl --batch "' . join(' ; ', @cmds) . '" >/dev/null');

log_msg("╰──────────────────────────────┴──────╯");
