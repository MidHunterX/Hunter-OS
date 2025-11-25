#!/usr/bin/env bash

PLACEHOLDER_COLOR="#2e3436"
CSS_FILE="$HOME/.config/wlogout/colors.css"
ICON_DIR="$HOME/.config/wlogout/icons"
OUTPUT_DIR="$HOME/.config/wlogout/color_icons"

# Make sure stuff exists
[ ! -f "$CSS_FILE" ] && exit 0
mkdir -p "$OUTPUT_DIR"

PRIMARY_COLOR=$(grep '@define-color primary ' "$CSS_FILE" | awk '{print $3}' | tr -d ';')

for svg in "$ICON_DIR"/*.svg; do
    base=$(basename "$svg")
    sed "s/fill=\"$PLACEHOLDER_COLOR\"/fill=\"$PRIMARY_COLOR\"/g" "$svg" >"$OUTPUT_DIR/$base"
done
