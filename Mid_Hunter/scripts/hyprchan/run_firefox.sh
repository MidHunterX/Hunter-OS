#!/usr/bin/bash
# Usage: run_firefox Profile_Name

# Read attribute
PROFILE=$1

# If attribute present, then convet to firefox attributes
if [[ $PROFILE ]]; then
  FF_ATTRIB="-P $PROFILE -no-remote "
fi

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
firefox-developer-edition $FF_ATTRIB &
