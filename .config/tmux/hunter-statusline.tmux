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
tmux set-option -g window-status-format " ${win_fmt} "
tmux set-option -g window-status-current-format "#[bg=${win_sel_bg},fg=${win_sel_fg}] ${win_fmt} "


# █▀█ █▀█ █▀▀ █▀▀ █ ▀▄▀   █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀
# █▀▀ █▀▄ ██▄ █▀░ █ █░█   █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄
pfx_sel_bg=$(get_tmux_option "@hunter-window-selected-bg" 'red')
pfx_sel_fg=$(get_tmux_option "@hunter-window-selected-fg" '#ffffff')
pfx_off="         "
pfx_sel=" COMMAND "
module="#[bg=default,fg=default,bold]#{?client_prefix,,${pfx_off}}#[bg=${pfx_sel_bg},fg=${pfx_sel_fg}]#{?client_prefix,${pfx_sel},}#[bg=default,fg=default,bold]"

tmux set-option -g status-left "${module}"
