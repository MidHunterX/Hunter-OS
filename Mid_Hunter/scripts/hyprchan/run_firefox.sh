#!/usr/bin/env bash
# Usage: run_firefox Profile_Name

# Failsafe mechanism for relative links
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

source ./profile/profile.sh
profile.hypr

# Read attribute
PROFILE=$1

# If attribute present, then convet to firefox attributes
if [[ $PROFILE ]]; then
  FF_ATTRIB="-P $PROFILE -no-remote "
fi

# Initial new tab (show once per day)
HIST_FILE=~/.cache/run_firefox_history.txt
if [ ! -f "$HIST_FILE" ]; then
  touch "$HIST_FILE"
  LAST_RUN_DATE=$(date --date="yesterday" +"%Y-%m-%d")
  echo $LAST_RUN_DATE > $HIST_FILE
fi

set_newtab () {
  if [[ $PROFILE == "Personal" ]]; then
    NEW_TAB_URL="https://app.daily.dev/"
    FF_ATTRIB+="-new-tab $NEW_TAB_URL"
  fi
}

LAST_RUN_DATE=$(cat $HIST_FILE)
TODAY=$(date +"%Y-%m-%d")
if [[ $LAST_RUN_DATE != $TODAY ]]; then
  set_newtab
  echo $(date +"%Y-%m-%d") > $HIST_FILE
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
      "There you go! Firefox, safe and sound."
      "Tada~! Found your Firefox, just where it was hiding."
      "Aha! Firefox located. I'm good at this, aren't I?"
      "Gotcha! Here's your Firefox, exactly where you left it."
      "Boom! Mission complete. Firefox is all yours."
      "Firefox, spotted and secured! You're welcome~"
      "Easy peasy! Your Firefox has been found."
      "Found it! Now go forth and browse!"
      "There it is! Right under our noses the whole time."
      "Firefox retrieved! I’m basically a window-finding pro."
      "Hah! It tried to hide, but nothing escapes Hypr Chan!"
      "All done~ Your Firefox is right here, ready for action."
      "Zoom~ Found your Firefox in record time!"
      "Another job well done! Here's your Firefox."
    )
    COMMENT=$(printf "%s\n" "${COMMENTS[@]}" | shuf -n 1)

    echo "$PROFILE Firefox Detected"
    hyprctl dispatch focuswindow pid:$PID
    hypr.message "$COMMENT"
    exit
  fi
}

check_firefox_running

# Hyprland Workspaces
if [[ $PROFILE == "Personal" ]]; then
  WORKSPACE='hyprctl dispatch -- exec [workspace 2]'
elif [[ $PROFILE == "Experiment" ]]; then
  WORKSPACE='hyprctl dispatch -- exec [workspace 3]'
fi

# Run Firefox if no running instance
$WORKSPACE firefox-developer-edition $FF_ATTRIB &
