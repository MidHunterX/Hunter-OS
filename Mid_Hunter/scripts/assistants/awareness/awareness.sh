#!/bin/bash
# Failsafe mechanism for relative links
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

PREV_WINDOW=""

# Creates following variables:
# ACTIVE_CLASS -> Class name of active window
# ACTIVE_TITLE -> Full title of active window
get_active_window() {
  ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r .class)
  ACTIVE_TITLE=$(hyprctl activewindow -j | jq -r .title)
}

# =========================== [ ADMIN FUNCTIONS ] =========================== #

main() {
  while true; do
    get_active_window

    if [[ "$ACTIVE_TITLE" != "$PREV_WINDOW" ]]; then
      CONTENT=$(python ./awareness.py "content" "$ACTIVE_CLASS" "$ACTIVE_TITLE")
      WINTYPE=$(python ./awareness.py "wintype" "$ACTIVE_CLASS" "$ACTIVE_TITLE")
      ACTION=$(python ./awareness.py "action" "$ACTIVE_CLASS" "$ACTIVE_TITLE")
      notify-send -t '3000' "$ACTIVE_CLASS" "$ACTION on $WINTYPE for $CONTENT"

      echo "$ACTIVE_TITLE"
      echo "$ACTIVE_CLASS" "$ACTION on $WINTYPE for $CONTENT"
      echo ""

      PREV_WINDOW=$ACTIVE_TITLE
    fi
    sleep 2
  done
}

main
exit
