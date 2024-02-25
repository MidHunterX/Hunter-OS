#!/bin/bash
SCRIPT=emoji-fuzzel.sh
sed -i '/^### DATA ###$/q' $SCRIPT #emoji-fuzzel.sh

curl https://raw.githubusercontent.com/muan/emojilib/main/dist/emoji-en-US.json \
  | jq --raw-output '. | to_entries | .[] | .key + " " + (.value | join(" ") | sub("_"; " "; "g"))' \
  >> $SCRIPT
