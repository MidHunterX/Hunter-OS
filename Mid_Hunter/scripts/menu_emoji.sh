#!/usr/bin/env bash

LABEL="Menu Emoji"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
source "./menu_lib.sh"

CACHE_FILE="$CACHE_DIR/emojis.txt"

# Update emojis cache if empty (one-time download)
if [ ! -s "$CACHE_FILE" ]; then
  update_emojis "$CACHE_FILE"
fi

ROW=$(show_menu "$CACHE_FILE" "󰱨 " "$LABEL" "#f9e2afff")

# Exit if nothing selected
[[ -z "$ROW" ]] && exit

if switch_if_menu "$ROW"; then
  exit
fi

# Symbol is first field
SYMBOL=$(echo "$ROW" | cut -d ' ' -f 1)
send_output "$SYMBOL"
bump_to_top "$ROW" "$CACHE_FILE"
