# This function is needed to execute admin functions
profile.hypr() {
  NAME="Hypr Chan"
  IMG=~/Mid_Hunter/scripts/hyprchan/profile/assets/hypr_chan.jpg
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
  notify-send $HINTS -t 5000 -i $IMG "$NAME" "$1"
}
