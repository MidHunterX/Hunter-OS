#!/bin/bash
source ~/Mid_Hunter/scripts/hyprchan/profile/profile.sh
profile.hypr

PREV_WINDOW=""

main() {
  while [[ true ]]; do
    # Get active window and class
    hypr.active_window
    # Check if focused window is changed
    if [[ "$ACTIVE_TITLE" != "$PREV_WINDOW" ]]; then

      CONTENT=$(python ./awareness_system.py "$ACTIVE_CLASS" "$ACTIVE_TITLE")
      notify-send -t '3000' "$ACTIVE_CLASS" "$CONTENT"

      # Update Previous Window
      PREV_WINDOW=$ACTIVE_TITLE
      echo $PREV_WINDOW
    fi
    sleep 2
  done
}

main
exit
