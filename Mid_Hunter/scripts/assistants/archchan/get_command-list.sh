#!/usr/bin/env bash

NAME='Arch Chan'

GRN='\033[1;32m'
BLU='\033[1;34m'
PNK='\033[1;35m'
RST='\033[0;0m'

CMD=$BLU # Command
ARG=$PNK # Arguments

animate_text() {
  local text="$1"
  local words=($text)
  for word in "${words[@]}"; do
    echo -n -e "$word "
    sleep 0.1
  done
  echo
}

# Initialize arrays
keywords=()
commands=()
comments=()

# Read a CSV file and process each line
while IFS=',' read -r col1 col2 col3; do
  keywords+=("$col1")
  commands+=("$col2")
  comments+=("$col3")
done <"$(dirname "$0")/get_command-list.csv"

usr_keyword=$(printf "%s\n" "${keywords[@]}" | fzf --border rounded --border-label "Arch Chan's Command List")

# Find the index of the selected keyword
index=-1
for i in "${!keywords[@]}"; do
  if [[ "${keywords[$i]}" == "$usr_keyword" ]]; then
    index=$i
    break
  fi
done

if [[ index -ne -1 ]]; then
  # Execute Command only if present
  if [[ ${commands[index]} != '' ]]; then
    echo -e "${GRN}${NAME}: ${RST}Executing ${CMD}${commands[$index]}${RST}\n"
    ${commands[$index]}
  fi
  # Additional Information
  comment="${comments[$index]}"
  formatted_comment=$(echo "$comment" | sed -E 's/"([^"]+)"/'"\\$CMD"'\1'"\\$RST"'/g; s/<([^>]+)>/'"\\$ARG"'<\1>'"\\$RST"'/g')
  animate_text "\n${GRN}${NAME}: ${RST}${formatted_comment}"
fi
