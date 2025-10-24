#!/usr/bin/env bash
# Theme Auto Switcher based on Wallpaper Brightness
# Requires: ImageMagick, swww (for wallpaper), gsettings

print_logs=false

# Hyprland Preference
light_brightness=0.2
dark_brightness=0.6
light_contrast=0.5
dark_contrast=0.8

log() {
  local grn='\033[1;32m'
  local rst='\033[0;0m'
  if $print_logs; then
    echo -e "[${grn}$(date +'%H:%M:%S')${rst}] $1"
  fi
}

error() {
  local red='\033[1;31m'
  local rst='\033[0;0m'
  echo -e "[${red}$(date +'%H:%M:%S')${rst}] $1"
}

# Linear Interpolation (lerp)
# Usage: lerp normalized_factor lower_value upper_value
lerp() {
  local g="$1" # normalized factor (0.0–1.0)
  local d="$2" # dark / lower value
  local l="$3" # light / upper value
  awk -v g="$g" -v d="$d" -v l="$l" 'BEGIN{print d + (g * (l - d))}'
}

# Step 1: Locate current wallpaper
CACHE_FILE="$HOME/.cache/swww/eDP-1"
WALLPAPER_PATH=$(strings "$CACHE_FILE" | grep -E '^/' | tail -n1)
if [[ -z "$WALLPAPER_PATH" || ! -f "$WALLPAPER_PATH" ]]; then
  error "Wallpaper not found or invalid: $WALLPAPER_PATH"
  exit 1
fi

log "🎨 Using wallpaper: $WALLPAPER_PATH"

# Step 2: Compute brightness (grayscale average of image)
TMP_IMG="/tmp/theme_color.jpeg"
magick "$WALLPAPER_PATH" -colorspace gray -resize 1x1 "$TMP_IMG" 2>/dev/null
if [[ ! -f "$TMP_IMG" ]]; then
  error "Failed to generate grayscale sample."
  exit 1
fi
GRAY_VALUE=$(magick "$TMP_IMG" txt: | awk -F'[()]' '/gray\(\w+\)/{print $2}')

percent=$(echo "$GRAY_VALUE" | awk '{printf "%.0f", $1/255*100}')

# Step 3: Choose theme based on brightness
THRESHOLD=127
if ((GRAY_VALUE > THRESHOLD)); then
  log "🌄 Light Wallpaper: $GRAY_VALUE/255 ($percent%)"
  # gsettings set org.gnome.desktop.interface gtk-theme Materia-light
else
  log "🌃 Dark Wallpaper: $GRAY_VALUE/255 ($percent%)"
  # gsettings set org.gnome.desktop.interface gtk-theme Materia-dark
fi

# Step 4: Autoscale brightness & contrast
g_norm=$(awk -v g="$GRAY_VALUE" 'BEGIN{print g/255}') # normalize 0–255 to 0–1

brightness=$(lerp "$g_norm" "$dark_brightness" "$light_brightness")
contrast=$(lerp "$g_norm" "$dark_contrast" "$light_contrast")

log "☀️ Brightness: $brightness"
log "🌗 Contrast: $contrast"

hyprctl keyword decoration:blur:brightness $brightness >/dev/null
hyprctl keyword decoration:blur:contrast $contrast >/dev/null
