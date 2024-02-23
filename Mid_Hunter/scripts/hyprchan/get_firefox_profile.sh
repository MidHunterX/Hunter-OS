#!/usr/bin/bash
# Usage: get_firefox Profile_Name

PROFILE=$1

# Checks and Moves focus if active instance found
check_firefox_running() {

  PROC=$(ps aux | grep "firefox -P $PROFILE" | head -n 1 | awk {printf'$13'})
  PID=$(ps aux | grep "firefox -P $PROFILE" | head -n 1 | awk {printf'$2'})

  # Change focus and exit script
  if [[ $PROC == $PROFILE ]]; then
    echo "$PROFILE Firefox Detected"
    hyprctl dispatch focuswindow pid:$PID
    exit
  fi
}

check_firefox_running

# Run Firefox if no running instance
firefox-developer-edition -P "$PROFILE" -no-remote &
