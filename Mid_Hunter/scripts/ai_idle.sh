#!/usr/bin/env bash

minutes() { echo $(($1 * 60)); }
TIMEOUT_MINOR=$(minutes 5)
TIMEOUT_MAJOR=$(minutes 15)

swayidle -w \
    timeout "$TIMEOUT_MINOR" 'hyprctl dispatch dpms off' \
    resume 'hyprctl dispatch dpms on' \
    timeout "$TIMEOUT_MAJOR" 'hyprctl dispatch dpms on; sleep 1; perl ~/Mid_Hunter/scripts/ai_idle_logic.pl' \
    resume 'hyprctl dispatch dpms on' &
