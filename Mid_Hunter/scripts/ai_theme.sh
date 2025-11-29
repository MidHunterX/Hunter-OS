#!/usr/bin/env bash
# Theme Auto Switcher based on Wallpaper Brightness
# Requires: ImageMagick, swww (for wallpaper), gsettings

print_logs=false
[[ "$1" == "--log" ]] && print_logs=true

MONITOR="eDP-1"
AUTOSCALE_STRATEGY="adapt" # custom | adapt

log() {
    local grn='\033[1;32m'
    local rst='\033[0;0m'
    if $print_logs; then
        echo -e "[${grn}$(date +'%H:%M:%S')${rst}] $1${rst}"
    fi
}

error() {
    local red='\033[1;31m'
    local rst='\033[0;0m'
    echo -e "[${red}$(date +'%H:%M:%S')${rst}] $1${rst}"
}

# usage: get_swww_wallpaper "monitor_name"
# returns: /path/to/wallpaper
get_swww_wallpaper() {
    local monitor cache_file wallpaper_path
    monitor="$1"
    cache_file="$HOME/.cache/swww/$monitor"
    wallpaper_path=$(strings "$cache_file" | grep -E '^/' | tail -n1)
    echo "$wallpaper_path"
}

# -----------------------------------------------------------------------------
# INITIALIZE
# -----------------------------------------------------------------------------

wallpaper=$(get_swww_wallpaper "$MONITOR")
if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
    error "Wallpaper not found or invalid: $wallpaper"
    exit 1
fi
log "🎨 Using wallpaper: $wallpaper"

TMP_IMG="/tmp/theme_color.jpeg"

# -----------------------------------------------------------------------------
# THEME BASED ON WALLPAPER COLOR
# -----------------------------------------------------------------------------

# Fast approximation based on Rec. 601 standard
# usage: hex_brightness "#RRGGBB"
hex_brightness() {
    local hex="${1#'#'}" # remove leading #
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    local brightness=$(((299 * r + 587 * g + 114 * b) / 1000))
    echo $brightness
}

# Convert hex color to ANSI escape sequence
# usage: hex_to_ansi "#RRGGBB" [bg]
# bg: optional argument to set background. If not provided, text color is set
hex_to_ansi() {
    local hex="${1#'#'}" # remove leading #
    local bg=$2
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    if [[ -n "$bg" ]]; then
        # Set text color
        (($(hex_brightness "$hex") < 128)) && printf '\033[38;2;255;255;255m' || printf '\033[38;2;0;0;0m'
        # Set background color
        printf '\033[48;2;%d;%d;%dm' "$r" "$g" "$b"
    else
        # Set text color only
        printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
    fi
}

# Compute theme color (RGB average of image)
# bias average-color sampling toward the center of the image by cropping border edges
CENTER_BIAS=10 # (0-100)
border=$((100 - CENTER_BIAS))
magick "$wallpaper" -gravity Center -crop ${border}%x${border}+0+0 -resize 1x1 "$TMP_IMG" 2>/dev/null
# magick "$wallpaper" -resize 1x1 "$TMP_IMG" 2>/dev/null
hex_value=$(magick "$TMP_IMG" txt: | awk '/#\w+/{print $3}')
log "🎨 Average Color: $(hex_to_ansi "$hex_value" invert)${hex_value}"

# matugen image "$WALLPAPER_PATH" --quiet
matugen color hex "$hex_value" --quiet

# -----------------------------------------------------------------------------
# THEME BASED ON LIGHT/DARK WALLPAPER
# -----------------------------------------------------------------------------

# Compute brightness (grayscale average of image)
luma_value=$(hex_brightness "$hex_value")
luma_percent=$(echo "$luma_value" | awk '{printf "%.0f", $1/255*100}')

if ((luma_percent > 50)); then
    log "🌄 Light Wallpaper: $luma_value/255 ($luma_percent%)"
    # gsettings set org.gnome.desktop.interface gtk-theme Materia-light
    # gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    # matugen image "$WALLPAPER_PATH" --mode "light" --quiet
else
    log "🌃 Dark Wallpaper: $luma_value/255 ($luma_percent%)"
    # gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
    # gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    # matugen image "$WALLPAPER_PATH" --mode "dark" --quiet
fi

# -----------------------------------------------------------------------------
# AUTOSCALE BRIGHTNESS & CONTRAST
# -----------------------------------------------------------------------------

# Linear Interpolation (lerp)
# Usage: lerp normalized_factor lower_value upper_value
# Where,
# normalized_factor = background brightness (0.0 to 1.0)
# lower_value = user preferred lower value like contrast, brightness, etc.
# upper_value = user preferred upper value like contrast, brightness, etc.
lerp() {
    local g="$1" # normalized factor (0.0–1.0)
    local d="$2" # dark / lower value
    local l="$3" # light / upper value
    awk -v g="$g" -v d="$d" -v l="$l" 'BEGIN{print d + (g * (l - d))}'
}

wallpaper_brightness=$(awk -v g="$luma_value" 'BEGIN{print g/255}') # normalize 0–255 to 0–1

case "$AUTOSCALE_STRATEGY" in
"custom")
    # Personal Preference
    min_brightness=0.2
    max_brightness=0.7
    min_contrast=0.5
    max_contrast=0.8

    brightness=$(lerp "$wallpaper_brightness" "$max_brightness" "$min_brightness")
    contrast=$(lerp "$wallpaper_brightness" "$max_contrast" "$min_contrast")
    ;;
"adapt")
    # wallpaper_brightness (0-1)
    # brightness (0-1)
    # contrast (0-2)

    target_darkness=0.6 # target percent of window darkness (0.0 - 1.0)
    # scale: how strong the adaptation should be
    # the lower the scale, the less adaptation between light and dark walls
    scale=0.6

    darkness_factor=$(awk -v g="$wallpaper_brightness" 'BEGIN{print 1 - g}')
    adapt=$(awk -v d="$darkness_factor" -v p="$target_darkness" 'BEGIN{print d - p}')

    brightness=$(awk -v a="$adapt" -v s="$scale" 'BEGIN{print 0.5 + (a * s)}')
    contrast=$(awk -v a="$adapt" -v s="$scale" 'BEGIN{print 0.7 + (a * s)}')
    ;;
*)
    brightness=1.0
    contrast=1.0
    ;;
esac

log "☀️ Window Brightness: $brightness"
log "🌗 Window Contrast: $contrast"

hyprctl keyword decoration:blur:brightness "$brightness" >/dev/null
hyprctl keyword decoration:blur:contrast "$contrast" >/dev/null
