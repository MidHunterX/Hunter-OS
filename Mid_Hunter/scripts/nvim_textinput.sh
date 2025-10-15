#!/usr/bin/env bash

set -euo pipefail

# log(str:message)
log() {
  local green='\033[1;32m'
  local reset='\033[0;0m'
  echo -e "[${green}$(date +'%H:%M:%S')${reset}] $1"
}

# check_dependencies(deps:array)
check_dependencies() {
  local deps=("$@")
  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      log "Error: '$cmd' is required but not installed."
      exit 1
    fi
  done
}

# create_tmpfile(tmp_dir:string, tmp_file:string)
create_tmpfile() {
  local tmp_dir=$1
  local tmp_file=$2
  [ -d "$tmp_dir" ] || mkdir -p "$tmp_dir"
  TEMP_FILE="$tmp_dir/$tmp_file"
  touch "$TEMP_FILE"
  chmod og-rwx "$TEMP_FILE"
}

# ================================== MAIN ================================== #

check_dependencies "nvim" "kitty" "wtype"

TEMP_DIR="/tmp/nvim-textinput"
TEMP_FILENAME="buffer.md"
create_tmpfile "$TEMP_DIR" "$TEMP_FILENAME"

# Launch Neovim in insert mode, auto-quit on write
TERM="kitty"
TERM_OPTS="--class textinput -e"
$TERM $TERM_OPTS nvim +startinsert +'autocmd BufWritePost <buffer> quit' "$TEMP_FILE"

# Paste the text if not empty
TEXT=$(<"$TEMP_FILE")
if [ -n "$TEXT" ]; then
  cat "$TEMP_FILE" | wl-copy -n
  wtype -M Ctrl -k v -m Ctrl
else
  exit 1
fi
