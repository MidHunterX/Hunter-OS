# vim: ft=sh

get_tmux_option() {
    local option=$1
    local def_val="$2"
    local usr_val
    usr_val=$(tmux show-options -gqv "$option")
    if [ -n "$usr_val" ]; then
        echo "$usr_val"
    else
        echo "$def_val"
    fi
}

# █▀█ █▀█ █▀▀ █▀▀ █ ▀▄▀   █▄▄ █░█ █ █░░ █▀▄ █▀▀ █▀█
# █▀▀ █▀▄ ██▄ █▀░ █ █░█   █▄█ █▄█ █ █▄▄ █▄▀ ██▄ █▀▄

# Creates a module segment that only appears when the tmux prefix key is active.
# Visual feedback for command mode.
function build_prefix_on() {
    local background foreground content module
    background=$1
    foreground=$2
    content=$3
    module="#[bg=${background},fg=${foreground}]#{?client_prefix,${content},}"
    module+="#[bg=default,fg=default]"
    echo "$module"
}

# Creates a module segment that appears only when the prefix is NOT active.
# Useful for showing alternative content during normal mode.
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

# Simple colored block with background and foreground.
# Basic building block for all modules.
function item() {
    local background foreground content
    background=$1
    foreground=$2
    content=$3
    echo "#[bg=${background},fg=${foreground}]${content}"
}

# Shows content normally, but changes background color when prefix is active.
# Visual cue for prefix mode.
function item_prefix() {
    local background foreground content module pfx_bg
    pfx_bg=$(get_tmux_option "@hunter_prefix_bg" 'red')
    background=$1
    foreground=$2
    content=$3
    module=$(build_prefix_off "$background" "$foreground" "$content")
    module+=$(build_prefix_on "$pfx_bg" 'default' "$content")
    echo "$module"
}

# Reverses colors during prefix mode (background becomes default, foreground
# becomes prefix color). Alternative visual style.
function item_prefix_inverted() {
    local background foreground content module pfx_fg
    pfx_fg=$(get_tmux_option "@hunter_prefix_bg" 'red')
    background=$1
    foreground=$2
    content=$3
    module=$(build_prefix_off "$background" "$foreground" "$content")
    module+=$(build_prefix_on 'default' "$pfx_fg" "$content")
    echo "$module"
}

# Only changes text color during prefix mode while keeping background.
# Subtle prefix indicator.
function item_prefix_text() {
    local background foreground content module pfx_fg
    pfx_fg=$(get_tmux_option "@hunter_prefix_fg" 'red')
    background=$1
    foreground=$2
    content=$3
    module=$(build_prefix_off "$background" "$foreground" "$content")
    module+=$(build_prefix_on "$background" "$pfx_fg" "$content")
    echo "$module"
}

# █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀ █▀
# █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄ ▄█

# Basic module with text only. Used for minimal, clean status bar items.
function build_simple_module() {
    local background foreground text module_format
    background=$1
    foreground=$2
    text=$3
    module_format="$(item 'default' 'default' " $text ")"
    echo "${module_format}"
}

function build_module_format_right() {
    local background foreground icon text module_format
    left_separator=$(get_tmux_option "@hunter_module_left_separator" "█")
    right_separator=$(get_tmux_option "@hunter_module_right_separator" "█")
    background=$1
    foreground=$2
    icon=$3
    text=$4

    module_format=" "
    module_format+=$(item_prefix_inverted 'default' "$background" "$left_separator")
    module_format+=$(item_prefix "$background" "$foreground" "$icon")
    module_format+=$(item_prefix "$background" "$foreground" ' ') # Space with BG
    module_format+=$(item_prefix_inverted 'default' "$background" "$right_separator")
    module_format+=$(item 'default' 'default' " $text ")
    module_format+=$(item_prefix_inverted 'default' "$background" '█')
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
    module_format+=$(item_prefix_inverted 'default' "$background" "$left_separator")
    module_format+=$(item 'default' 'default' " $text ")
    module_format+=$(item_prefix_inverted 'default' "$background" "$right_separator")
    module_format+=$(item_prefix "$background" "$foreground" "$icon")
    module_format+=$(item_prefix "$background" "$foreground" ' ') # Space with BG
    module_format+=$(item_prefix_inverted 'default' "$background" '')
    module_format+=" "

    echo "${module_format}"
}

# MODULE: Session Name
function session_module_config() {
    local background foreground icon text
    background=$(get_tmux_option '@hunter_module_session_bg' 'gray')
    foreground=$(get_tmux_option '@hunter_module_session_fg' '#000000')
    icon=$(get_tmux_option "@hunter_module_session_icon" '')
    text=$(get_tmux_option '@hunter_module_session_text' '#S')
    # build_module_format_right $background $foreground $icon $text
    build_simple_module "$background" "$foreground" "$icon $text"
}

# MODULE: Current Time
function time_module_config() {
    local background foreground icon text
    background=$(get_tmux_option '@hunter_module_time_bg' 'gray')
    foreground=$(get_tmux_option '@hunter_module_time_bg' '#000000')
    icon=$(get_tmux_option "@hunter_module_time_icon" '󰥔')
    text=$(get_tmux_option '@hunter_module_time_text' "%H%M")
    # build_module_format_left $background $foreground $icon $text
    build_simple_module "$background" "$foreground" "$icon $text"
}

# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█ █▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄█

# Formats non-active window tabs with separators.
# Clean visual distinction between windows.
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
    window_format+="$(item 'default' "$background" "$left_separator")"
    window_format+="$(item_prefix_text "$background" "$foreground" "$number")"
    window_format+="$(item 'default' "$background" "$right_separator")"
    window_format+=" "
    window_format+="$(item 'default' "$text_color" "$text")"
    window_format+=" "

    echo "${window_format}"
}

# Special formatting for the active window. Makes current window stand out.
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
    window_format+="$(item_prefix_inverted 'default' "$background" "$left_separator")"
    window_format+="$(item_prefix "$background" "$foreground" "$number")"
    window_format+="$(item_prefix_inverted 'default' "$background" "$right_separator")"

    window_format+=" "
    window_format+="$(item 'default' "$text_color" "$text")"
    window_format+=" "

    echo "${window_format}"
}

# Configures appearance of active window (highlighted with blue background).
function current_window_config() {
    local background foreground number text text_color
    background=$(get_tmux_option '@hunter_window_current_bg' 'blue')
    foreground=$(get_tmux_option '@hunter_window_current_fg' '#000000,bold')
    number='#I'
    text=$(get_tmux_option '@hunter_window_current_text' '#W')
    text_color=$(get_tmux_option '@hunter_window_current_text_color' '#ffffff,bold')
    build_current_window_format "$background" "$foreground" "$number" "$text" "$text_color"
}

# Configures appearance of inactive windows (black background).
function default_window_config() {
    local background foreground number text text_color
    background=$(get_tmux_option '@hunter_window_default_bg' 'black')
    foreground=$(get_tmux_option '@hunter_window_default_fg' 'white')
    number='#I'
    text=$(get_tmux_option '@hunter_window_default_text' '#W')
    text_color=$(get_tmux_option '@hunter_window_default_text_color' 'default')
    build_window_format "$background" "$foreground" $number "$text" "$text_color"
}

tmux set-option -g window-status-format "$(default_window_config)"
tmux set-option -g window-status-current-format "$(current_window_config)"

# █▀ ▀█▀ ▄▀█ ▀█▀ █░█ █▀   █░░ █ █▄░█ █▀▀
# ▄█ ░█░ █▀█ ░█░ █▄█ ▄█   █▄▄ █ █░▀█ ██▄
status_pos=$(get_tmux_option "@hunter-status-position" "bottom")
status_jus=$(get_tmux_option "@hunter-status-justify" "absolute-centre")
tmux set-option -g status-style bg=default,fg=default
tmux set-option -g status-position "${status_pos}"
tmux set-option -g status-justify "${status_jus}"

# █▀ ▀█▀ ▄▀█ ▀█▀ █░█ █▀   █▀▄▀█ █▀█ █▀▄ █░█ █░░ █▀▀ █▀
# ▄█ ░█░ █▀█ ░█░ █▄█ ▄█   █░▀░█ █▄█ █▄▀ █▄█ █▄▄ ██▄ ▄█
tmux set-option -g status-right-length 69
tmux set-option -g status-left-length 69

# Uncomment any or concat var strings for more
tmux set-option -g status-left "$(session_module_config)"
tmux set-option -g status-right "$(time_module_config)"
