#!/usr/bin/bash
# Usage: run_firefox Profile_Name

# source $(dirname "$0")/hyprchan.sh
source ~/Mid_Hunter/scripts/hyprchan/hyprchan.sh
profile.hypr

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

    COMMENTS=(
      "I found what you're looking for. It's right here."
      "Look no further! I've found exactly what you need."
      "Found it! It was right here."
      "Aha! Here's what you've been searching for."
      "Mission accomplished! I've located what you're looking for."
      "Found it! Here it is."
      "Here it is! I found what you're after."
      "The thing you're looking for is right here."
      "Got it! I've found the item you were searching for."
      "Search complete! I've found the missing piece."
    )
    COMMENT=$(printf "%s\n" "${COMMENTS[@]}" | shuf -n 1)

    echo "$PROFILE Firefox Detected"
    hyprctl dispatch focuswindow pid:$PID
    hypr.message "$COMMENT"
    exit
  fi
}

check_firefox_running

# Run Firefox if no running instance
firefox-developer-edition $FF_ATTRIB &
