#!/usr/bin/env bash

STRATEGY="seismic" # "gradient" | "seismic"

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
    local h=$((10#$1)) # force base-10 immediately
    ((h < 0)) && echo "23" && return
    ((h > 23)) && echo "00" && return
    echo "$h"
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
    PREV_HOUR=$(clamp_hour $((THIS_HOUR - 1)))
    NEXT_HOUR=$(clamp_hour $((THIS_HOUR + 1)))

    # Zero pad
    THIS_HOUR=$(printf "%02d" "$THIS_HOUR")
    PREV_HOUR=$(printf "%02d" "$PREV_HOUR")
    NEXT_HOUR=$(printf "%02d" "$NEXT_HOUR")
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

# procedure: updates change throughout the day starting from current hour
# usage: generate_seismic_shift from_hour from_val
generate_seismic_shift() {
    local from_hour="$1"
    local from_val="$2"

    local old_var="BR_${from_hour}_00"
    local old_val="${!old_var}"

    # How much the curve should move
    local delta
    delta=$(calc "${from_val} - ${old_val}")
    [[ "$delta" == "0" ]] && return

    echo -e "${YLO}Seismic shift Δ=${delta} starting @ ${from_hour}:00${RESET}"

    # Walk through all future hours (including wrap-around)
    local h=$((10#$from_hour))
    for ((i = h; i < 24; i++)); do
        local hour
        hour=$(clamp_hour "$h")

        # Stop once we loop back to previous hour
        [[ "$hour" == "$PREV_HOUR" ]] && break

        # Update hour anchor
        local base_var="BR_${hour}_00"
        local base_val="${!base_var}"
        local new_base
        new_base=$(calc "${base_val} + ${delta}")
        update_config_value "$base_var" "$new_base"

        # Update 15-min divisions
        local div=0
        for ((j = 1; j < DIVISIONS; j++)); do
            div=$((10#$div + INTERVALS))
            printf -v div "%02d" "$div"

            local var="BR_${hour}_${div}"
            local val="${!var}"

            # Skip undefined entries safely
            [[ -z "$val" ]] && continue

            local new_val
            new_val=$(calc "${val} + ${delta}")
            update_config_value "$var" "$new_val"
            echo -e "${YLO}${var} = ${new_val}${RESET}"
        done

        h=$((10#$h + 1))
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

    update_config_value "$THIS_VAR" "$current_brightness"
    THIS_VAL="$current_brightness"

    case "$STRATEGY" in
    gradient)
        echo -e "${YLO}${PREV_VAR} = ${PREV_VAL} # PREV${RESET}"
        generate_gradient "$PREV_HOUR" "$THIS_HOUR" "$PREV_VAL" "$THIS_VAL"
        echo -e "${GRN}${THIS_VAR} = ${THIS_VAL} # THIS${RESET}"
        generate_gradient "$THIS_HOUR" "$NEXT_HOUR" "$THIS_VAL" "$NEXT_VAL"
        echo -e "${BLU}${NEXT_VAR} = ${NEXT_VAL} # NEXT${RESET}"
        echo -e "\n${GRN}Local Brightness interpolation updated successfully.${RESET}"
        ;;
    seismic)
        generate_seismic_shift "$THIS_HOUR" "$THIS_VAL"
        echo -e "\n${GRN}Global Brightness temporal translation successful.${RESET}"
        ;;
    *) ;;
    esac
}

main "$@"
