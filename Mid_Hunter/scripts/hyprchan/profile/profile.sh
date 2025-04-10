# This function is needed to execute admin functions
profile.hypr() {
  # Failsafe mechanism for relative links
  local SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

  NAME="Hypr Chan"
  IMG="$SOURCE/assets/hypr_chan.jpg"
  HINTS="-h string:frcolor:#52efb3 "
  HINTS+="-h string:bgcolor:#1f4738 "
}

# ========================== [ MEMORY FUNCTIONS ] ========================== #

# Creates following variables:
# ACTIVE_CLASS -> Class name of active window
# ACTIVE_TITLE -> Full title of active window
hypr.active_window() {
  ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r .class)
  ACTIVE_TITLE=$(hyprctl activewindow -j | jq -r .title)
}

# =========================== [ ADMIN FUNCTIONS ] =========================== #

hypr.message() {
  local TIMEOUT=1000
  notify-send -t $TIMEOUT $HINTS -i $IMG "$NAME" "$1"
}
