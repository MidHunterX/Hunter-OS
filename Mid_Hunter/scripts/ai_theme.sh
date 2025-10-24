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
  local green='\033[1;32m'
  local reset='\033[0;0m'
  if $print_logs; then
    echo -e "[${green}$(date +'%H:%M:%S')${reset}] $1"
  fi
}

error() {
  local red='\033[1;31m'
  local reset='\033[0;0m'
  if $print_logs; then
    echo -e "[${red}$(date +'%H:%M:%S')${reset}] $1"
  fi
}

# Step 1: Locate current wallpaper
CACHE_FILE="$HOME/.cache/swww/eDP-1"
# it’s a binary-like file, so use strings
# cat ~/.cache/swww/eDP-1
# ^@Lanczos3^@path/to/wallpaper.jpg^@
WALLPAPER_PATH=$(strings "$CACHE_FILE" | grep -E '^/' | tail -n1)
if [[ -z "$WALLPAPER_PATH" || ! -f "$WALLPAPER_PATH" ]]; then
  error "❌ Wallpaper not found or invalid: $WALLPAPER_PATH"
  exit 1
fi

log "🎨 Using wallpaper: $WALLPAPER_PATH"

# Step 2: Compute brightness (grayscale average of image)
TMP_IMG="/tmp/theme_color.jpeg"
magick "$WALLPAPER_PATH" -colorspace gray -resize 1x1 "$TMP_IMG" 2>/dev/null
if [[ ! -f "$TMP_IMG" ]]; then
  error "❌ Failed to generate grayscale sample."
  exit 1
fi
GRAY_VALUE=$(magick "$TMP_IMG" txt: | awk -F'[()]' '/gray/{print $2}' | awk '{print $1}')
if [[ -z "$GRAY_VALUE" ]]; then
  error "❌ Could not extract gray value."
  exit 1
fi

GRAY_VALUE=$(echo $GRAY_VALUE | awk '{print int($1)}')
percent=$(echo "$GRAY_VALUE" | awk '{printf "%.0f", $1/255*100}')

# Step 3: Choose theme based on brightness
THRESHOLD=127
if ((GRAY_VALUE > THRESHOLD)); then
  type="Light"
else
  type="Dark"
fi

log "🌄 $type Wallpaper: $GRAY_VALUE/255 ($percent% Bright)"

# Step 4: Autoscale brightness & contrast
g_norm=$(awk -v g="$GRAY_VALUE" 'BEGIN{print g/255}') # normalize 0–255 to 0–1

brightness=$(awk -v g="$g_norm" -v d="$dark_brightness" -v l="$light_brightness" 'BEGIN{print d - (g * (d - l))}')
contrast=$(awk -v g="$g_norm" -v d="$dark_contrast" -v l="$light_contrast" 'BEGIN{print d + (g * (l - d))}')

# clamp values just to be safe
brightness=$(awk -v v="$brightness" 'BEGIN{if(v<0)v=0;if(v>2)v=2;print v}')
contrast=$(awk -v v="$contrast" 'BEGIN{if(v<0)v=0;if(v>2)v=2;print v}')

log "☀️ Brightness: $brightness"
log "🌗 Contrast: $contrast"

hyprctl keyword decoration:blur:brightness $brightness
hyprctl keyword decoration:blur:contrast $contrast
