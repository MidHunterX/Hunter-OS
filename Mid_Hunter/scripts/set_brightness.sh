#!/usr/bin/env bash

BLU='\033[0;34m'
YLO='\033[0;33m'
GRN='\033[1;32m'
RESET='\033[0;0m'

CONFIG_FILE="${HOME}/Mid_Hunter/scripts/set_brightness.conf"
INTERVALS=15
DIVISIONS=$((60 / INTERVALS))

[[ -f "$CONFIG_FILE" ]] || {
  echo "Config file not found: $CONFIG_FILE" >&2
  exit 1
}
source "$CONFIG_FILE"

calc() {
  local result
  result=$(awk "BEGIN {print $*}")

  if [[ "$result" =~ ^-?[0-9]+$ ]]; then
    printf "%d" "$result"
  else
    printf "%.2f" "$result"
  fi
}

update_config_value() {
  local key="$1" val="$2"
  sed -i "s/\(${key} *= *\).*/\1${val}/" "$CONFIG_FILE"
}

clamp_hour() {
  local h="$1"
  ((h < 0)) && echo "23" && return
  ((h > 23)) && echo "00" && return
  printf "%02d" "$h"
}

# Returns:
# var $THIS_HOUR
# var $PREV_HOUR
# var $NEXT_HOUR
get_time_context() {
  local hour minute
  hour=$(date +"%H")
  minute=$(date +"%M")
  # Jump to next datapoint if >30 min
  ((minute > 30)) && hour=$((10#$hour + 1))
  THIS_HOUR=$(clamp_hour "$hour")
  PREV_HOUR=$(clamp_hour $((10#$THIS_HOUR - 1)))
  NEXT_HOUR=$(clamp_hour $((10#$THIS_HOUR + 1)))
}

# procedure: prints out gradient, updates config
# usage: generate_gradient from_hour to_hour from_val to_val
generate_gradient() {
  local from_hour="$1" _="$2" from_val="$3" to_val="$4"

  local diff step
  diff=$(calc "${to_val} - ${from_val}")
  step=$(calc "${diff} / ${DIVISIONS}")

  local div_point=0
  for ((i = 1; i < DIVISIONS; i++)); do
    div_point=$((10#$div_point + INTERVALS))
    printf -v div_point "%02d" "$div_point"
    local var="BR_${from_hour}_${div_point}"
    local val
    val=$(calc "${from_val} + (${step} * ${i})")
    echo "${var} = ${val}"
    update_config_value "$var" "$val"
  done
}

main() {
  local current_brightness
  current_brightness=$(brillo)

  get_time_context

  # Resolve brightness vars dynamically
  local PREV_VAR="BR_${PREV_HOUR}_00"
  local THIS_VAR="BR_${THIS_HOUR}_00"
  local NEXT_VAR="BR_${NEXT_HOUR}_00"

  local PREV_VAL="${!PREV_VAR}"
  local THIS_VAL="${!THIS_VAR}"
  local NEXT_VAL="${!NEXT_VAR}"

  # Average current & stored brightness
  local AVG_BR
  AVG_BR=$(calc "(${THIS_VAL} + ${current_brightness}) / 2")
  update_config_value "$THIS_VAR" "$AVG_BR"
  THIS_VAL="$AVG_BR"

  echo -e "${YLO}${PREV_VAR} = ${PREV_VAL} # PREV${RESET}"
  generate_gradient "$PREV_HOUR" "$THIS_HOUR" "$PREV_VAL" "$THIS_VAL"
  echo -e "${GRN}${THIS_VAR} = ${THIS_VAL} # THIS${RESET}"
  generate_gradient "$THIS_HOUR" "$NEXT_HOUR" "$THIS_VAL" "$NEXT_VAL"
  echo -e "${BLU}${NEXT_VAR} = ${NEXT_VAL} # NEXT${RESET}"

  echo -e "\n${GRN}Brightness interpolation updated successfully.${RESET}"
}

main "$@"
