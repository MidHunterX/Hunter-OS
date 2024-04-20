#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# ENVIRONMENT VARIABLESS #
# ====================== #

export EDITOR=nvim

# Forcing XDG spec
export GOPATH="$HOME/.cache/go"
# Obeying XDG User directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# Obeying XDG System directories
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"


# AUTO-START HYPRLAND #
# =================== #
if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    dbus-run-session Hyprland > /dev/null
fi


# Disable the bell
if [[ $iatest > 0 ]]; then bind "set bell-style visible"; fi

# Don't put duplicate lines in the history
export HISTCONTROL=ignoredups
# Disable Bash History File
unset HISTFILE

# Vi mode
set -o vi
# History
set -o history
# Autocompletion
complete -cf sudo


# ============================ [ COLOUR STUFF ] ============================ #

PS1='[\u@\h \W]\$ '
# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
alias grep="/usr/bin/grep $GREP_OPTIONS"
unset GREP_OPTIONS
alias ls='ls --color=auto'
alias grep='grep --color=auto'


# LS Colors
export LS_COLORS='no=00:fi=00:di=00;34:ow=40;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'


function __setprompt {
  local LAST_COMMAND=$? # Must come first!
  # Define colors
  local LIGHTGRAY="\033[0;37m"
  local WHITE="\033[1;37m"
  local BLACK="\033[0;30m"
  local DARKGRAY="\033[1;30m"
  local RED="\033[0;31m"
  local LIGHTRED="\033[1;31m"
  local GREEN="\033[0;32m"
  local LIGHTGREEN="\033[1;32m"
  local BROWN="\033[0;33m"
  local YELLOW="\033[1;33m"
  local BLUE="\033[0;34m"
  local LIGHTBLUE="\033[1;34m"
  local MAGENTA="\033[0;35m"
  local LIGHTMAGENTA="\033[1;35m"
  local CYAN="\033[0;36m"
  local LIGHTCYAN="\033[1;36m"
  local NOCOLOR="\033[0m"

  # [midhunter@Flex-5 .config]$
  # Show error exit code if there is one
  if [[ $LAST_COMMAND != 0 ]]; then
    PS1="${RED}(${LIGHTRED}ERROR${RED})-(${LIGHTRED}Exit Code ${WHITE}${LAST_COMMAND}${RED})-(${LIGHTRED}"
    if [[ $LAST_COMMAND == 1 ]]; then PS1+="General error"
    elif [ $LAST_COMMAND == 2 ]; then PS1+="Missing keyword, command, or permission problem"
    elif [ $LAST_COMMAND == 126 ]; then PS1+="Permission problem or command is not an executable"
    elif [ $LAST_COMMAND == 127 ]; then PS1+="Command not found"
    elif [ $LAST_COMMAND == 128 ]; then PS1+="Invalid argument to exit"
    elif [ $LAST_COMMAND == 129 ]; then PS1+="Fatal error signal 1"
    elif [ $LAST_COMMAND == 130 ]; then PS1+="Script terminated by Control-C"
    elif [ $LAST_COMMAND == 131 ]; then PS1+="Fatal error signal 3"
    elif [ $LAST_COMMAND == 132 ]; then PS1+="Fatal error signal 4"
    elif [ $LAST_COMMAND == 133 ]; then PS1+="Fatal error signal 5"
    elif [ $LAST_COMMAND == 134 ]; then PS1+="Fatal error signal 6"
    elif [ $LAST_COMMAND == 135 ]; then PS1+="Fatal error signal 7"
    elif [ $LAST_COMMAND == 136 ]; then PS1+="Fatal error signal 8"
    elif [ $LAST_COMMAND == 137 ]; then PS1+="Fatal error signal 9"
    elif [ $LAST_COMMAND -gt 255 ]; then PS1+="Exit status out of range"
    else
      PS1+="Unknown error code"
    fi
    PS1+="${RED})${NOCOLOR}\n"
  else
    PS1=""
  fi

  # Skip to the next line
  PS1+="\n"

  # User and server
  local SSH_IP=`echo $SSH_CLIENT | awk '{ print $1 }'`
  local SSH2_IP=`echo $SSH2_CLIENT | awk '{ print $1 }'`
  if [ $SSH2_IP ] || [ $SSH_IP ] ; then
    PS1+="${LIGHTGRAY}(${RED}\u@\h"
  else
    PS1+="${LIGHTGRAY}(${RED}\u"
  fi

  # Current directory
  PS1+="${LIGHTGRAY}:${BROWN}\w${LIGHTGRAY})-"

  # Number of files
  PS1+="(${GREEN}\$(/bin/ls -A -1 | /usr/bin/wc -l) Items${LIGHTGRAY})"

  # Skip to the next line
  PS1+="\n"

  if [[ $EUID -ne 0 ]]; then
    PS1+="${GREEN}>${NOCOLOR} " # Normal user
  else
    PS1+="${RED}ROOT >${NOCOLOR} " # Root user
  fi

  # PS2 is used to continue a command using the \ character
  PS2="${DARKGRAY}>${NOCOLOR} "

  # PS3 is used to enter a number choice in a script
  PS3='Please enter a number from above list: '

  # PS4 is used for tracing a script in debug mode
  PS4='${DARKGRAY}+${NOCOLOR} '
}
PROMPT_COMMAND='__setprompt'


# ============================ [ CUSTOM STUFF ] ============================ #

# Neovim
alias mid='nvim'

# Brightness
alias brs='bash ~/Mid_Hunter/scripts/set_brightness.sh'

# Volume
alias vos='bash ~/Mid_Hunter/scripts/set_volume.sh'

# vicd Function
vicd() {
  local dst="$(command vifm --choose-dir - "$@")"
  if [ -z "$dst" ]; then
    echo 'Directory picking cancelled/failed'
    return 1
  fi
  cd "$dst"
}
