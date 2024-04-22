#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local def_val="$2"
  local usr_val=$(tmux show-options -gqv "$option")
  if [ -n "$usr_val" ]; then
    echo "$usr_val"
  else
    echo "$def_val"
  fi
}


# █▀█ █▀█ █▀▀ █▀▀ █ ▀▄▀   █▄▄ █░█ █ █░░ █▀▄ █▀▀ █▀█
# █▀▀ █▀▄ ██▄ █▀░ █ █░█   █▄█ █▄█ █ █▄▄ █▄▀ ██▄ █▀▄

function build_prefix_on() {
  local bg fg content module
  bg=$1
  fg=$2
  content=$3
  module="#[bg=${bg},fg=${fg}]#{?client_prefix,${content},}"
  module+="#[bg=default,fg=default]"
  echo "$module"
}

function build_prefix_off() {
  local bg fg content module
  bg=$1
  fg=$2
  content=$3
  module="#[bg=${bg},fg=${fg}]#{?client_prefix,,${content}}"
  module+="#[bg=default,fg=default]"
  echo "$module"
}


# █ ▀█▀ █▀▀ █▀▄▀█ █▀
# █ ░█░ ██▄ █░▀░█ ▄█

item() {
  background=$1
  foreground=$2
  content=$3
  echo "#[bg=${background},fg=${foreground}]${content}"
}

item_prefix() {
  local bg fg content module
  bg=$1
  fg=$2
  content=$3
  module="$(build_prefix_off $bg $fg "$content")"
  module+="$(build_prefix_on 'red' '#000000' "$content")"
  echo "$module"
}

item_prefix_inverted() {
  local bg fg content module
  bg=$1
  fg=$2
  content=$3
  module="$(build_prefix_off $bg $fg "$content")"
  module+="$(build_prefix_on '#000000' 'red' "$content")"
  echo "$module"
}



# █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀ █▀
# █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄ ▄█

build_module_format() {
  left_separator=$(get_tmux_option "@hunter_module_left_separator" "█")
  right_separator=$(get_tmux_option "@hunter_module_right_separator" "█")

  local background foreground icon text module_format
  background=$1
  foreground=$2
  icon=$3
  text=$4

  module_format=" "
  module_format+="$(item 'default' $background $left_separator)"
  module_format+="$(item $background $foreground $icon) "
  module_format+="$(item 'default' $background $right_separator)"
  module_format+=" "
  module_format+="$(item 'default' 'default' $text)"
  module_format+=" "

  echo "${module_format}"
}

session_module_config() {
  local background foreground icon text
  background=$(get_tmux_option '@hunter_window_current_bg' 'yellow')
  foreground=$(get_tmux_option '@hunter_window_current_fg' '#000000')
  icon=$(get_tmux_option "@hunter_module_session_icon" '')
  text=$(get_tmux_option '@hunter_module_session_text' '#S')
  build_module_format $background $foreground $icon $text
}



# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█ █▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄█

build_window_format() {
  left_separator=$(get_tmux_option '@hunter_window_left_separator' '█')
  right_separator=$(get_tmux_option '@hunter_window_right_separator' '█')

  local background foreground number text text_color window_format
  background=$1
  foreground=$2
  number=$3
  text=$4
  text_color=$5

  window_format=""
  window_format+="$(item 'default' $background $left_separator)"
  window_format+="$(item $background $foreground $number)"
  window_format+="$(item 'default' $background $right_separator)"
  window_format+=" "
  window_format+="$(item 'default' $text_color $text)"
  window_format+=" "

  echo "${window_format}"
}

current_window_config() {
  local number color background text text_color
  background=$(get_tmux_option '@hunter_window_current_bg' 'blue')
  foreground=$(get_tmux_option '@hunter_window_current_fg' '#000000,bold')
  number='#I'
  text=$(get_tmux_option '@hunter_window_current_text' '#W')
  text_color=$(get_tmux_option '@hunter_window_current_text_color' '#ffffff,bold')
  build_window_format $background $foreground $number $text $text_color
}

default_window_config() {
  local number color background text text_color
  background=$(get_tmux_option '@hunter_window_default_bg' 'black')
  foreground=$(get_tmux_option '@hunter_window_default_fg' 'white')
  number='#I'
  text=$(get_tmux_option '@hunter_window_default_text' '#W')
  text_color=$(get_tmux_option '@hunter_window_default_text_color' 'default')
  build_window_format $background $foreground $number $text $text_color
}



# █▀ ▀█▀ ▄▀█ ▀█▀ █░█ █▀   █░░ █ █▄░█ █▀▀
# ▄█ ░█░ █▀█ ░█░ █▄█ ▄█   █▄▄ █ █░▀█ ██▄
status_pos=$(get_tmux_option "@hunter-status-position" "bottom")
status_jus=$(get_tmux_option "@hunter-status-justify" "centre")
tmux set-option -g status-position "${status_pos}"
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-justify "${status_jus}"


# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█ █▀   █░░ █ █▀ ▀█▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄█   █▄▄ █ ▄█ ░█░
win_sel_bg=$(get_tmux_option "@hunter-window-selected-bg" 'blue')
win_sel_fg=$(get_tmux_option "@hunter-window-selected-fg" '#000000')
win_fmt=$(get_tmux_option "@hunter-window-format" '#I:#W')
# tmux set-option -g window-status-format " ${win_fmt} "
tmux set-option -g window-status-format "$(default_window_config)"
# tmux set-option -g window-status-current-format "#[bg=${win_sel_bg},fg=${win_sel_fg}] ${win_fmt} "
tmux set-option -g window-status-current-format "$(current_window_config)"


# █▀█ █▀█ █▀▀ █▀▀ █ ▀▄▀   █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀
# █▀▀ █▀▄ ██▄ █▀░ █ █░█   █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄
pfx_sel_bg=$(get_tmux_option "@hunter-prefix-selected-bg" 'red')
pfx_sel_fg=$(get_tmux_option "@hunter-prefix-selected-fg" '#000000,bold')
pfx_off="          "
pfx_sel="  PREFIX  "
module="$(build_prefix_off 'default' 'default' "$pfx_off")$(build_prefix_on $pfx_sel_bg $pfx_sel_fg "$pfx_sel")"

tmux set-option -g status-left "${module}"

tmux set-option -g status-right "$(session_module_config)"
