#!/usr/bin/env bash

# Failsafe mechanism for relative links
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR

update_unicode_emojis() {
  SCRIPT=menu_emoji.sh
  sed -i '/^### EMOJI LIST ###$/q' $SCRIPT
  curl https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json \
    | jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' \
    >> $SCRIPT
}

update_nerd_symbols() {
  SCRIPT=menu_nerdfont.sh
  local nerd all
  sed -i '/^### NF LIST ###$/q' $SCRIPT
  nerd=$(curl -sSL "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/css/nerd-fonts-generated.css")
  all+=$(printf "%s" "$nerd" | sed -ne '/\.nf-/p' -e '/\s*[^_]content:/p' | sed -e 'N;s/^\.nf-\(.*\):before.* content: \"\\\(.*\)\";/\\U\2 \1/')
  echo -e "$all" >> $SCRIPT
}

update_unicode_emojis
update_nerd_symbols
