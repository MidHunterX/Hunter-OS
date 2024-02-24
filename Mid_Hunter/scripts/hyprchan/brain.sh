hypr.active_window() {
  ACTIVE_CLASS=$(hyprctl activewindow -j | jq -r .class)
  ACTIVE_TITLE=$(hyprctl activewindow -j | jq -r .title)
}

