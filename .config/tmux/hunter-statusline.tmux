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
  local background foreground content module
  background=$1
  foreground=$2
  content=$3
  module="#[bg=${background},fg=${foreground}]#{?client_prefix,${content},}"
  module+="#[bg=default,fg=default]"
  echo "$module"
}

function build_prefix_off() {
  local background foreground content module
  background=$1
  foreground=$2
  content=$3
  module="#[bg=${background},fg=${foreground}]#{?client_prefix,,${content}}"
  module+="#[bg=default,fg=default]"
  echo "$module"
}


# █ ▀█▀ █▀▀ █▀▄▀█ █▀
# █ ░█░ ██▄ █░▀░█ ▄█

function item() {
  local background foreground content
  background=$1
  foreground=$2
  content=$3
  echo "#[bg=${background},fg=${foreground}]${content}"
}

function item_prefix() {
  local background foreground content module
  background=$1
  foreground=$2
  content=$3
  module="$(build_prefix_off $background $foreground "$content")"
  module+="$(build_prefix_on 'red' '#000000' "$content")"
  echo "$module"
}

function item_prefix_inverted() {
  local background foreground content module
  background=$1
  foreground=$2
  content=$3
  module="$(build_prefix_off $background $foreground "$content")"
  module+="$(build_prefix_on '#000000' 'red' "$content")"
  echo "$module"
}

function item_prefix_text() {
  local background foreground content module
  background=$1
  foreground=$2
  content=$3
  module="$(build_prefix_off $background $foreground "$content")"
  module+="$(build_prefix_on $background 'red' "$content")"
  echo "$module"
}


# █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀ █▀
# █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄ ▄█

# █    █    █

function build_module_format() {
  local background foreground icon text module_format
  left_separator=$(get_tmux_option "@hunter_module_left_separator" "█")
  right_separator=$(get_tmux_option "@hunter_module_right_separator" "█")
  background=$1
  foreground=$2
  icon=$3
  text=$4

  module_format=" "
  module_format+="$(item_prefix_inverted 'default' $background $left_separator)"
  module_format+="$(item_prefix $background $foreground $icon)"
  module_format+="$(item_prefix $background $foreground ' ')" # Space with BG
  module_format+="$(item_prefix_inverted 'default' $background $right_separator)"
  module_format+="$(item_prefix_text 'default' 'default' " $text ")"
  module_format+="$(item_prefix_inverted 'default' $background '█')"
  module_format+=" "

  echo "${module_format}"
}

function build_module_format_left() {
  local background foreground icon text module_format
  left_separator=$(get_tmux_option "@hunter_module_left_separator" "█")
  right_separator=$(get_tmux_option "@hunter_module_right_separator" "██")
  background=$1
  foreground=$2
  icon=$3
  text=$4

  module_format=" "
  module_format+="$(item_prefix_inverted 'default' $background $left_separator)"
  module_format+="$(item_prefix_text 'default' 'default' " $text ")"
  module_format+="$(item_prefix_inverted 'default' $background $right_separator)"
  module_format+="$(item_prefix $background $foreground $icon)"
  module_format+="$(item_prefix $background $foreground ' ')" # Space with BG
  module_format+="$(item_prefix_inverted 'default' $background '')"
  module_format+=" "

  echo "${module_format}"
}

function session_module_config() {
  local background foreground icon text
  background=$(get_tmux_option '@hunter_module_session_bg' 'gray')
  foreground=$(get_tmux_option '@hunter_module_session_bg' '#000000')
  icon=$(get_tmux_option "@hunter_module_session_icon" '')
  text=$(get_tmux_option '@hunter_module_session_text' '#S')
  build_module_format $background $foreground $icon $text
}

function time_module_config() {
  local background foreground icon text
  background=$(get_tmux_option '@hunter_module_time_bg' 'gray')
  foreground=$(get_tmux_option '@hunter_module_time_bg' '#000000')
  icon=$(get_tmux_option "@hunter_module_time_icon" '󰥔')
  text=$(get_tmux_option '@hunter_module_time_text' "%m%d-%H%M")
  build_module_format_left $background $foreground $icon $text
}


# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█ █▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄█

function build_window_format() {
  local background foreground number text text_color window_format
  left_separator=$(get_tmux_option '@hunter_window_left_separator' '█')
  right_separator=$(get_tmux_option '@hunter_window_right_separator' '█')
  background=$1
  foreground=$2
  number=$3
  text=$4
  text_color=$5

  window_format=""
  window_format+="$(item 'default' $background $left_separator)"
  window_format+="$(item_prefix_text $background $foreground $number)"
  window_format+="$(item 'default' $background $right_separator)"
  window_format+=" "
  window_format+="$(item 'default' $text_color $text)"
  window_format+=" "

  echo "${window_format}"
}

function build_current_window_format() {
  local background foreground number text text_color window_format
  left_separator=$(get_tmux_option '@hunter_window_left_separator' '█')
  right_separator=$(get_tmux_option '@hunter_window_right_separator' '█')
  background=$1
  foreground=$2
  number=$3
  text=$4
  text_color=$5

  window_format=""
  window_format+="$(item_prefix_inverted 'default' $background $left_separator)"
  window_format+="$(item_prefix $background $foreground $number)"
  window_format+="$(item_prefix_inverted 'default' $background $right_separator)"

  window_format+=" "
  window_format+="$(item 'default' $text_color $text)"
  window_format+=" "

  echo "${window_format}"
}

function current_window_config() {
  local background foreground number text text_color
  background=$(get_tmux_option '@hunter_window_current_bg' 'blue')
  foreground=$(get_tmux_option '@hunter_window_current_fg' '#000000,bold')
  number='#I'
  text=$(get_tmux_option '@hunter_window_current_text' '#W')
  text_color=$(get_tmux_option '@hunter_window_current_text_color' '#ffffff,bold')
  build_current_window_format $background $foreground $number $text $text_color
}

function default_window_config() {
  local background foreground number text text_color
  background=$(get_tmux_option '@hunter_window_default_bg' 'black')
  foreground=$(get_tmux_option '@hunter_window_default_fg' 'white')
  number='#I'
  text=$(get_tmux_option '@hunter_window_default_text' '#W')
  text_color=$(get_tmux_option '@hunter_window_default_text_color' 'default')
  build_window_format $background $foreground $number $text $text_color
}

tmux set-option -g window-status-format "$(default_window_config)"
tmux set-option -g window-status-current-format "$(current_window_config)"



# █▀ ▀█▀ ▄▀█ ▀█▀ █░█ █▀   █░░ █ █▄░█ █▀▀
# ▄█ ░█░ █▀█ ░█░ █▄█ ▄█   █▄▄ █ █░▀█ ██▄
status_pos=$(get_tmux_option "@hunter-status-position" "bottom")
status_jus=$(get_tmux_option "@hunter-status-justify" "centre")
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-position "${status_pos}"
tmux set-option -g status-justify "${status_jus}"



# █▀█ █▀█ █▀▀ █▀▀ █ ▀▄▀   █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀
# █▀▀ █▀▄ ██▄ █▀░ █ █░█   █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄
pfx_sel_bg=$(get_tmux_option "@hunter-prefix-selected-bg" 'red')
pfx_sel_fg=$(get_tmux_option "@hunter-prefix-selected-fg" '#000000,bold')
pfx_off="          "
pfx_sel="  PREFIX  "
module="$(build_prefix_off 'default' 'default' "$pfx_off")"
module+="$(build_prefix_on $pfx_sel_bg $pfx_sel_fg "$pfx_sel")"
# tmux set-option -g status-left "${module}"
tmux set-option -g status-left "$(time_module_config)"

tmux set-option -g status-right "$(session_module_config)"
tmux set-option -g status-right-length 69
tmux set-option -g status-left-length 69
