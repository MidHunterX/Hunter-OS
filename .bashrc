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
# unset HISTFILE

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


# LS_COLORS (8-BIT)
# =================

# SYSTEM STUFF
LS_COLORS=''
LS_COLORS+='no=00:'             # NORMAL - Global default
LS_COLORS+='fi=00:'             # FILE
LS_COLORS+='di=34;01:'          # DIR
LS_COLORS+='ow=42;30;01:'       # OTHER_WRITABLE
LS_COLORS+='bd=40;33;01:'       # BLOCK Device
LS_COLORS+='cd=40;33;01:'       # CHARACTER Device
LS_COLORS+='ex=01;32:'          # Executable File
LS_COLORS+='ln=01;36:'          # SYMLINK
LS_COLORS+='or=40;31;01:'       # ORPHAN SYMLINK
LS_COLORS+='pi=40;33:'          # Named PIPE, FIFO
LS_COLORS+='so=01;35:'          # SOCK Socket
LS_COLORS+='do=01;35:'          # DOOR
# EXTENSION STUFF
LS_COLORS+='*.a=1;38;5;210:'
LS_COLORS+='*.c=0;38;5;150:'
LS_COLORS+='*.d=0;38;5;150:'
LS_COLORS+='*.h=0;38;5;150:'
LS_COLORS+='*.m=0;38;5;150:'
LS_COLORS+='*.o=0;38;5;60:'
LS_COLORS+='*.p=0;38;5;150:'
LS_COLORS+='*.r=0;38;5;150:'
LS_COLORS+='*.t=0;38;5;150:'
LS_COLORS+='*.z=4;38;5;116:'
LS_COLORS+='*.7z=4;38;5;116:'
LS_COLORS+='*.as=0;38;5;150:'
LS_COLORS+='*.bc=0;38;5;60:'
LS_COLORS+='*.bz=4;38;5;116:'
LS_COLORS+='*.cc=0;38;5;150:'
LS_COLORS+='*.cp=0;38;5;150:'
LS_COLORS+='*.cr=0;38;5;150:'
LS_COLORS+='*.cs=0;38;5;150:'
LS_COLORS+='*.di=0;38;5;150:'
LS_COLORS+='*.el=0;38;5;150:'
LS_COLORS+='*.ex=0;38;5;150:'
LS_COLORS+='*.fs=0;38;5;150:'
LS_COLORS+='*.go=0;38;5;150:'
LS_COLORS+='*.gv=0;38;5;150:'
LS_COLORS+='*.gz=4;38;5;116:'
LS_COLORS+='*.hh=0;38;5;150:'
LS_COLORS+='*.hi=0;38;5;60:'
LS_COLORS+='*.hs=0;38;5;150:'
LS_COLORS+='*.jl=0;38;5;150:'
LS_COLORS+='*.js=0;38;5;150:'
LS_COLORS+='*.ko=1;38;5;210:'
LS_COLORS+='*.kt=0;38;5;150:'
LS_COLORS+='*.la=0;38;5;60:'
LS_COLORS+='*.ll=0;38;5;150:'
LS_COLORS+='*.lo=0;38;5;60:'
LS_COLORS+='*.md=0;38;5;223:'
LS_COLORS+='*.ml=0;38;5;150:'
LS_COLORS+='*.mn=0;38;5;150:'
LS_COLORS+='*.nb=0;38;5;150:'
LS_COLORS+='*.pl=0;38;5;150:'
LS_COLORS+='*.pm=0;38;5;150:'
LS_COLORS+='*.pp=0;38;5;150:'
LS_COLORS+='*.ps=0;38;5;210:'
LS_COLORS+='*.py=0;38;5;150:'
LS_COLORS+='*.rb=0;38;5;150:'
LS_COLORS+='*.rm=0;38;5;224:'
LS_COLORS+='*.rs=0;38;5;150:'
LS_COLORS+='*.sh=0;38;5;150:'
LS_COLORS+='*.so=1;38;5;210:'
LS_COLORS+='*.td=0;38;5;150:'
LS_COLORS+='*.ts=0;38;5;150:'
LS_COLORS+='*.ui=0;38;5;223:'
LS_COLORS+='*.vb=0;38;5;150:'
LS_COLORS+='*.wv=0;38;5;224:'
LS_COLORS+='*.xz=4;38;5;116:'
LS_COLORS+='*.aif=0;38;5;224:'
LS_COLORS+='*.ape=0;38;5;224:'
LS_COLORS+='*.apk=4;38;5;116:'
LS_COLORS+='*.arj=4;38;5;116:'
LS_COLORS+='*.asa=0;38;5;150:'
LS_COLORS+='*.aux=0;38;5;60:'
LS_COLORS+='*.avi=0;38;5;224:'
LS_COLORS+='*.awk=0;38;5;150:'
LS_COLORS+='*.bag=4;38;5;116:'
LS_COLORS+='*.bak=0;38;5;60:'
LS_COLORS+='*.bat=1;38;5;210:'
LS_COLORS+='*.bbl=0;38;5;60:'
LS_COLORS+='*.bcf=0;38;5;60:'
LS_COLORS+='*.bib=0;38;5;223:'
LS_COLORS+='*.bin=4;38;5;116:'
LS_COLORS+='*.blg=0;38;5;60:'
LS_COLORS+='*.bmp=0;38;5;224:'
LS_COLORS+='*.bsh=0;38;5;150:'
LS_COLORS+='*.bst=0;38;5;223:'
LS_COLORS+='*.bz2=4;38;5;116:'
LS_COLORS+='*.c++=0;38;5;150:'
LS_COLORS+='*.cfg=0;38;5;223:'
LS_COLORS+='*.cgi=0;38;5;150:'
LS_COLORS+='*.clj=0;38;5;150:'
LS_COLORS+='*.com=1;38;5;210:'
LS_COLORS+='*.cpp=0;38;5;150:'
LS_COLORS+='*.css=0;38;5;150:'
LS_COLORS+='*.csv=0;38;5;223:'
LS_COLORS+='*.csx=0;38;5;150:'
LS_COLORS+='*.cxx=0;38;5;150:'
LS_COLORS+='*.deb=4;38;5;116:'
LS_COLORS+='*.def=0;38;5;150:'
LS_COLORS+='*.dll=1;38;5;210:'
LS_COLORS+='*.dmg=4;38;5;116:'
LS_COLORS+='*.doc=0;38;5;210:'
LS_COLORS+='*.dot=0;38;5;150:'
LS_COLORS+='*.dox=0;38;5;116:'
LS_COLORS+='*.dpr=0;38;5;150:'
LS_COLORS+='*.elc=0;38;5;150:'
LS_COLORS+='*.elm=0;38;5;150:'
LS_COLORS+='*.epp=0;38;5;150:'
LS_COLORS+='*.eps=0;38;5;224:'
LS_COLORS+='*.erl=0;38;5;150:'
LS_COLORS+='*.exe=1;38;5;210:'
LS_COLORS+='*.exs=0;38;5;150:'
LS_COLORS+='*.fls=0;38;5;60:'
LS_COLORS+='*.flv=0;38;5;224:'
LS_COLORS+='*.fnt=0;38;5;224:'
LS_COLORS+='*.fon=0;38;5;224:'
LS_COLORS+='*.fsi=0;38;5;150:'
LS_COLORS+='*.fsx=0;38;5;150:'
LS_COLORS+='*.gif=0;38;5;224:'
LS_COLORS+='*.git=0;38;5;60:'
LS_COLORS+='*.gvy=0;38;5;150:'
LS_COLORS+='*.h++=0;38;5;150:'
LS_COLORS+='*.hpp=0;38;5;150:'
LS_COLORS+='*.htc=0;38;5;150:'
LS_COLORS+='*.htm=0;38;5;223:'
LS_COLORS+='*.hxx=0;38;5;150:'
LS_COLORS+='*.ico=0;38;5;224:'
LS_COLORS+='*.ics=0;38;5;210:'
LS_COLORS+='*.idx=0;38;5;60:'
LS_COLORS+='*.ilg=0;38;5;60:'
LS_COLORS+='*.img=4;38;5;116:'
LS_COLORS+='*.inc=0;38;5;150:'
LS_COLORS+='*.ind=0;38;5;60:'
LS_COLORS+='*.ini=0;38;5;223:'
LS_COLORS+='*.inl=0;38;5;150:'
LS_COLORS+='*.ipp=0;38;5;150:'
LS_COLORS+='*.iso=4;38;5;116:'
LS_COLORS+='*.jar=4;38;5;116:'
LS_COLORS+='*.jpg=0;38;5;224:'
LS_COLORS+='*.kex=0;38;5;210:'
LS_COLORS+='*.kts=0;38;5;150:'
LS_COLORS+='*.log=0;38;5;60:'
LS_COLORS+='*.ltx=0;38;5;150:'
LS_COLORS+='*.lua=0;38;5;150:'
LS_COLORS+='*.m3u=0;38;5;224:'
LS_COLORS+='*.m4a=0;38;5;224:'
LS_COLORS+='*.m4v=0;38;5;224:'
LS_COLORS+='*.mid=0;38;5;224:'
LS_COLORS+='*.mir=0;38;5;150:'
LS_COLORS+='*.mkv=0;38;5;224:'
LS_COLORS+='*.mli=0;38;5;150:'
LS_COLORS+='*.mov=0;38;5;224:'
LS_COLORS+='*.mp3=0;38;5;224:'
LS_COLORS+='*.mp4=0;38;5;224:'
LS_COLORS+='*.mpg=0;38;5;224:'
LS_COLORS+='*.nix=0;38;5;223:'
LS_COLORS+='*.odp=0;38;5;210:'
LS_COLORS+='*.ods=0;38;5;210:'
LS_COLORS+='*.odt=0;38;5;210:'
LS_COLORS+='*.ogg=0;38;5;224:'
LS_COLORS+='*.org=0;38;5;223:'
LS_COLORS+='*.otf=0;38;5;224:'
LS_COLORS+='*.out=0;38;5;60:'
LS_COLORS+='*.pas=0;38;5;150:'
LS_COLORS+='*.pbm=0;38;5;224:'
LS_COLORS+='*.pdf=0;38;5;210:'
LS_COLORS+='*.pgm=0;38;5;224:'
LS_COLORS+='*.php=0;38;5;150:'
LS_COLORS+='*.pid=0;38;5;60:'
LS_COLORS+='*.pkg=4;38;5;116:'
LS_COLORS+='*.png=0;38;5;224:'
LS_COLORS+='*.pod=0;38;5;150:'
LS_COLORS+='*.ppm=0;38;5;224:'
LS_COLORS+='*.pps=0;38;5;210:'
LS_COLORS+='*.ppt=0;38;5;210:'
LS_COLORS+='*.pro=0;38;5;116:'
LS_COLORS+='*.ps1=0;38;5;150:'
LS_COLORS+='*.psd=0;38;5;224:'
LS_COLORS+='*.pyc=0;38;5;60:'
LS_COLORS+='*.pyd=0;38;5;60:'
LS_COLORS+='*.pyo=0;38;5;60:'
LS_COLORS+='*.rar=4;38;5;116:'
LS_COLORS+='*.rpm=4;38;5;116:'
LS_COLORS+='*.rst=0;38;5;223:'
LS_COLORS+='*.rtf=0;38;5;210:'
LS_COLORS+='*.sbt=0;38;5;150:'
LS_COLORS+='*.sql=0;38;5;150:'
LS_COLORS+='*.sty=0;38;5;60:'
LS_COLORS+='*.svg=0;38;5;224:'
LS_COLORS+='*.swf=0;38;5;224:'
LS_COLORS+='*.swp=0;38;5;60:'
LS_COLORS+='*.sxi=0;38;5;210:'
LS_COLORS+='*.sxw=0;38;5;210:'
LS_COLORS+='*.tar=4;38;5;116:'
LS_COLORS+='*.tbz=4;38;5;116:'
LS_COLORS+='*.tcl=0;38;5;150:'
LS_COLORS+='*.tex=0;38;5;150:'
LS_COLORS+='*.tgz=4;38;5;116:'
LS_COLORS+='*.tif=0;38;5;224:'
LS_COLORS+='*.tml=0;38;5;223:'
LS_COLORS+='*.tmp=0;38;5;60:'
LS_COLORS+='*.toc=0;38;5;60:'
LS_COLORS+='*.tsx=0;38;5;150:'
LS_COLORS+='*.ttf=0;38;5;224:'
LS_COLORS+='*.txt=0;38;5;223:'
LS_COLORS+='*.vcd=4;38;5;116:'
LS_COLORS+='*.vim=0;38;5;150:'
LS_COLORS+='*.vob=0;38;5;224:'
LS_COLORS+='*.wav=0;38;5;224:'
LS_COLORS+='*.wma=0;38;5;224:'
LS_COLORS+='*.wmv=0;38;5;224:'
LS_COLORS+='*.xcf=0;38;5;224:'
LS_COLORS+='*.xlr=0;38;5;210:'
LS_COLORS+='*.xls=0;38;5;210:'
LS_COLORS+='*.xml=0;38;5;223:'
LS_COLORS+='*.xmp=0;38;5;223:'
LS_COLORS+='*.yml=0;38;5;223:'
LS_COLORS+='*.zip=4;38;5;116:'
LS_COLORS+='*.zsh=0;38;5;150:'
LS_COLORS+='*.zst=4;38;5;116:'
LS_COLORS+='*TODO=1:'
LS_COLORS+='*hgrc=0;38;5;116:'
LS_COLORS+='*.bash=0;38;5;150:'
LS_COLORS+='*.conf=0;38;5;223:'
LS_COLORS+='*.dart=0;38;5;150:'
LS_COLORS+='*.diff=0;38;5;150:'
LS_COLORS+='*.docx=0;38;5;210:'
LS_COLORS+='*.epub=0;38;5;210:'
LS_COLORS+='*.fish=0;38;5;150:'
LS_COLORS+='*.flac=0;38;5;224:'
LS_COLORS+='*.h264=0;38;5;224:'
LS_COLORS+='*.hgrc=0;38;5;116:'
LS_COLORS+='*.html=0;38;5;223:'
LS_COLORS+='*.java=0;38;5;150:'
LS_COLORS+='*.jpeg=0;38;5;224:'
LS_COLORS+='*.json=0;38;5;223:'
LS_COLORS+='*.less=0;38;5;150:'
LS_COLORS+='*.lisp=0;38;5;150:'
LS_COLORS+='*.lock=0;38;5;60:'
LS_COLORS+='*.make=0;38;5;116:'
LS_COLORS+='*.mpeg=0;38;5;224:'
LS_COLORS+='*.opus=0;38;5;224:'
LS_COLORS+='*.orig=0;38;5;60:'
LS_COLORS+='*.pptx=0;38;5;210:'
LS_COLORS+='*.psd1=0;38;5;150:'
LS_COLORS+='*.psm1=0;38;5;150:'
LS_COLORS+='*.purs=0;38;5;150:'
LS_COLORS+='*.rlib=0;38;5;60:'
LS_COLORS+='*.sass=0;38;5;150:'
LS_COLORS+='*.scss=0;38;5;150:'
LS_COLORS+='*.tbz2=4;38;5;116:'
LS_COLORS+='*.tiff=0;38;5;224:'
LS_COLORS+='*.toml=0;38;5;223:'
LS_COLORS+='*.webm=0;38;5;224:'
LS_COLORS+='*.webp=0;38;5;224:'
LS_COLORS+='*.woff=0;38;5;224:'
LS_COLORS+='*.xbps=4;38;5;116:'
LS_COLORS+='*.xlsx=0;38;5;210:'
LS_COLORS+='*.yaml=0;38;5;223:'
LS_COLORS+='*.cabal=0;38;5;150:'
LS_COLORS+='*.cache=0;38;5;60:'
LS_COLORS+='*.class=0;38;5;60:'
LS_COLORS+='*.cmake=0;38;5;116:'
LS_COLORS+='*.dyn_o=0;38;5;60:'
LS_COLORS+='*.ipynb=0;38;5;150:'
LS_COLORS+='*.mdown=0;38;5;223:'
LS_COLORS+='*.patch=0;38;5;150:'
LS_COLORS+='*.scala=0;38;5;150:'
LS_COLORS+='*.shtml=0;38;5;223:'
LS_COLORS+='*.swift=0;38;5;150:'
LS_COLORS+='*.toast=4;38;5;116:'
LS_COLORS+='*.xhtml=0;38;5;223:'
LS_COLORS+='*README=0;38;5;235;48;5;223:'
LS_COLORS+='*passwd=0;38;5;223:'
LS_COLORS+='*shadow=0;38;5;223:'
LS_COLORS+='*.config=0;38;5;223:'
LS_COLORS+='*.dyn_hi=0;38;5;60:'
LS_COLORS+='*.flake8=0;38;5;116:'
LS_COLORS+='*.gradle=0;38;5;150:'
LS_COLORS+='*.groovy=0;38;5;150:'
LS_COLORS+='*.ignore=0;38;5;116:'
LS_COLORS+='*.matlab=0;38;5;150:'
LS_COLORS+='*COPYING=0;38;5;247:'
LS_COLORS+='*INSTALL=0;38;5;235;48;5;223:'
LS_COLORS+='*LICENSE=0;38;5;247:'
LS_COLORS+='*TODO.md=1:'
LS_COLORS+='*.desktop=0;38;5;223:'
LS_COLORS+='*.gemspec=0;38;5;116:'
LS_COLORS+='*Doxyfile=0;38;5;116:'
LS_COLORS+='*Makefile=0;38;5;116:'
LS_COLORS+='*TODO.txt=1:'
LS_COLORS+='*setup.py=0;38;5;116:'
LS_COLORS+='*.DS_Store=0;38;5;60:'
LS_COLORS+='*.cmake.in=0;38;5;116:'
LS_COLORS+='*.fdignore=0;38;5;116:'
LS_COLORS+='*.kdevelop=0;38;5;116:'
LS_COLORS+='*.markdown=0;38;5;223:'
LS_COLORS+='*.rgignore=0;38;5;116:'
LS_COLORS+='*COPYRIGHT=0;38;5;247:'
LS_COLORS+='*README.md=0;38;5;235;48;5;223:'
LS_COLORS+='*configure=0;38;5;116:'
LS_COLORS+='*.gitconfig=0;38;5;116:'
LS_COLORS+='*.gitignore=0;38;5;116:'
LS_COLORS+='*.localized=0;38;5;60:'
LS_COLORS+='*.scons_opt=0;38;5;60:'
LS_COLORS+='*CODEOWNERS=0;38;5;116:'
LS_COLORS+='*Dockerfile=0;38;5;223:'
LS_COLORS+='*INSTALL.md=0;38;5;235;48;5;223:'
LS_COLORS+='*README.txt=0;38;5;235;48;5;223:'
LS_COLORS+='*SConscript=0;38;5;116:'
LS_COLORS+='*SConstruct=0;38;5;116:'
LS_COLORS+='*.gitmodules=0;38;5;116:'
LS_COLORS+='*.synctex.gz=0;38;5;60:'
LS_COLORS+='*.travis.yml=0;38;5;150:'
LS_COLORS+='*INSTALL.txt=0;38;5;235;48;5;223:'
LS_COLORS+='*LICENSE-MIT=0;38;5;247:'
LS_COLORS+='*MANIFEST.in=0;38;5;116:'
LS_COLORS+='*Makefile.am=0;38;5;116:'
LS_COLORS+='*Makefile.in=0;38;5;60:'
LS_COLORS+='*.applescript=0;38;5;150:'
LS_COLORS+='*.fdb_latexmk=0;38;5;60:'
LS_COLORS+='*CONTRIBUTORS=0;38;5;235;48;5;223:'
LS_COLORS+='*appveyor.yml=0;38;5;150:'
LS_COLORS+='*configure.ac=0;38;5;116:'
LS_COLORS+='*.clang-format=0;38;5;116:'
LS_COLORS+='*.gitattributes=0;38;5;116:'
LS_COLORS+='*.gitlab-ci.yml=0;38;5;150:'
LS_COLORS+='*CMakeCache.txt=0;38;5;60:'
LS_COLORS+='*CMakeLists.txt=0;38;5;116:'
LS_COLORS+='*LICENSE-APACHE=0;38;5;247:'
LS_COLORS+='*CONTRIBUTORS.md=0;38;5;235;48;5;223:'
LS_COLORS+='*.sconsign.dblite=0;38;5;60:'
LS_COLORS+='*CONTRIBUTORS.txt=0;38;5;235;48;5;223:'
LS_COLORS+='*requirements.txt=0;38;5;116:'
LS_COLORS+='*package-lock.json=0;38;5;60:'
LS_COLORS+='*.CFUserTextEncoding=0;38;5;60'
export LS_COLORS


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

history -c
