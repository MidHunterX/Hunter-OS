#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/menu-cache"
mkdir -p "$CACHE_DIR"

# Menu registry: "Label:script"
declare -A MENU_REGISTRY=(
  ["Emoji Menu"]="menu_emoji.sh"
  ["Font Menu"]="menu_nerdfont.sh"
)

# update_emojis <cache_file>
update_emojis() {
  local cache_file=$1
  curl -sSL https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json |
    jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' \
      >"$cache_file"
}

# update_nerdfonts <cache_file>
update_nerdfonts() {
  local cache_file=$1
  curl -sSL "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/css/nerd-fonts-generated.css" |
    sed -ne '/\.nf-/p' -e '/\s*[^_]content:/p' |
    sed -e 'N;s/^\.nf-\(.*\):before.* content: \"\\\(.*\)\";/\\U\2 \1/' |
    while IFS= read -r line; do
      # interpret \Uxxxx into actual char
      echo -e "$line"
    done >"$cache_file"
}

ensure_cache() {
  local cache_file=$1
  [ -f "$cache_file" ] || touch "$cache_file"
}

get_switch_entries() {
  local current=$1
  for label in "${!MENU_REGISTRY[@]}"; do
    if [[ $label != "$current" ]]; then
      echo "$label"
    fi
  done
}

# show_menu <cache_file> <prompt> <switch_label> <color>
show_menu() {
  local cache_file=$1
  local prompt=$2
  local switch_label=$3
  local color=$4
  ensure_cache "$cache_file"
  local selection=$(
    (
      sed '/^$/d' "$cache_file"
      get_switch_entries "$switch_label"
    ) | fuzzel --dmenu \
      --border-color="$color" \
      --background="#2d2d379b" \
      --match-mode=fzf \
      --prompt="$prompt "
  )
  echo "$selection"
}

# switch_if_menu <selected_label>
switch_if_menu() {
  local selection=$1
  if [[ -n ${MENU_REGISTRY[$selection]:-} ]]; then
    bash "$SCRIPT_DIR/${MENU_REGISTRY[$selection]}" &
    return 0
  fi
  return 1
}

bump_to_top() {
  local row=$1
  local cache_file=$2
  if grep -q "^$row$" "$cache_file"; then
    sed -i "/^$row$/d" "$cache_file"
  fi
  sed -i "1i $row" "$cache_file"
}

send_output() {
  local symbol=$1
  wtype "$symbol"
  wl-copy "$symbol"
}
