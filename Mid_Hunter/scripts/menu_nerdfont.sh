#!/usr/bin/env bash

LABEL="Menu Nerd Font"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
source "./menu_lib.sh"

CACHE_FILE="$CACHE_DIR/nerdfonts.txt"

# Update nerd fonts cache if empty (one-time download)
if [ ! -s "$CACHE_FILE" ]; then
  update_nerdfonts "$CACHE_FILE"
fi

ROW=$(show_menu "$CACHE_FILE" "󰀺" "$LABEL" "#89b4faff")

# Exit if nothing selected
[[ -z "$ROW" ]] && exit

if switch_if_menu "$ROW"; then
  exit
fi

# Symbol is first field
SYMBOL=$(echo "$ROW" | cut -d ' ' -f 1)
send_output "$SYMBOL"
bump_to_top "$ROW" "$CACHE_FILE"
