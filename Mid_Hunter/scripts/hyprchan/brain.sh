# Creates following variables:
# ACTIVE_CLASS -> Class name of active window
# ACTIVE_TITLE -> Full title of active window
hypr.active_window() {
  ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r .class)
  ACTIVE_TITLE=$(hyprctl activewindow -j | jq -r .title)
}

