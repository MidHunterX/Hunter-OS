#!/usr/bin/env bash

# benchmark_start=$(date +%N)

# █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀
# ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█
# ============================
# ICO='  '   # Classic Dots
# ICO='🯇🯅🯈 '  # Groupism
# ICO='⣿⣿⣿ '  # Air Vent
# ICO='▜▙  '  # Egyptian Snek
# ICO='█ '  # Sharp Edges
# ICO=''  # Caution Stripes
ICO=''  # Tigerstripes
# 1=100% 2=50% 3=33% 4=25% 5=20%
BAR_SCALING=5
# Some Icons: 🬋 ━ ≡ = ◍◌ ▮▯
BAR_FILL='🬋'
BAR_REST='🬋'


# █░█ ▄▀█ █▀█ █ ▄▀█ █▄▄ █░░ █▀▀ █▀
# ▀▄▀ █▀█ █▀▄ █ █▀█ █▄█ █▄▄ ██▄ ▄█
# ================================
BLK='\033[1;30m' RED='\033[1;31m' GRN='\033[1;32m' YLO='\033[1;33m'
BLU='\033[1;34m' PNK='\033[1;35m' CYN='\033[1;36m' WHT='\033[1;37m'
DEF='\033[0;39m' RESET='\033[0;0m'
U='\033[4m' # Underline
R=${RESET}
X=${BLU} # Accent 1
Y=${YLO} # Accent 2
H=${BLU} # Heading
L=${WHT} # Line
B=${GRN} # Bold
V=${YLO} # Values

ceil_div() {
  echo $(( ($1 + $2 - 1) / $2 ))
}

generate_bar() {
  VALUE=$1
  BAR_FILL=$2
  BAR=""
  # echo -n $(( VALUE / BAR_SCALING ))
  if (( VALUE / BAR_SCALING > 0 )); then
    BAR=$(echo "$(printf "${BAR_FILL}%.0s" $(seq 1 $(ceil_div VALUE BAR_SCALING)))")
  fi
  echo $BAR
}


# █▀▄ ▄▀█ ▀█▀ ▄▀█
# █▄▀ █▀█ ░█░ █▀█
# ===============
# uptime=$(uptime -p | awk -F'( |,)+' '{print $2,$3,$4,$5}')
uptime=$(uptime -p)
read -r hr hr_label min min_label <<< "$(awk -F'( |,)+' '{print $2,$3,$4,$5}' <<< "$uptime")"
UPTIME="${V}${hr}${R} ${hr_label} ${V}${min}${R} ${min_label}"

# COST: 52ms
# PAK_EXPLICIT=$(pacman -Qeq | wc -l)
# PAK_DEPENDEN=$(pacman -Qdq | wc -l)
# PAK_TOTAL=$((PAK_EXPLICIT + PAK_DEPENDEN))
# echo -e "                           ${B}Packages:${R} $PAK_EXPLICIT + $PAK_DEPENDEN = $PAK_TOTAL"

BAR_FRACTION=${BAR_SCALING}
ROUNDOFF=${BAR_SCALING}

BAT_PERCENT=$(cat /sys/class/power_supply/BAT0/capacity)
BAT_ROUND=$((BAT_PERCENT - (BAT_PERCENT%ROUNDOFF)))
BAT_REST=$((100-$BAT_ROUND))
BAT_BAR=$(generate_bar $BAT_ROUND $BAR_FILL)
BAT_REST_BAR=$(generate_bar $BAT_REST $BAR_REST)

BAT_WATT=$(cat /sys/class/power_supply/BAT0/power_now | awk '{ printf "%.1f\n", $1 / 1000000 }')
BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status)

RAM_VALUE=$(free | grep Mem: | awk '{printf "%d", $3/1024}')  # Return in MB
RAM_PERCENT=$(free | grep Mem: | awk '{printf "%d", $3/$2 * 100}')
RAM_ROUND=$((RAM_PERCENT - (RAM_PERCENT%ROUNDOFF)))
RAM_REST=$((100-RAM_ROUND))
RAM_BAR=$(generate_bar $RAM_ROUND $BAR_FILL)
RAM_REST_BAR=$(generate_bar $RAM_REST $BAR_REST)

SSD_PERCENT=$(df -h /dev/nvme0n1p5 | awk 'NR==2 {print $5}' | sed 's/%//')
SSD_ROUND=$((SSD_PERCENT - (SSD_PERCENT%ROUNDOFF)))
SSD_REST=$((100-SSD_ROUND))
SSD_BAR=$(generate_bar $SSD_ROUND $BAR_FILL)
SSD_REST_BAR=$(generate_bar $SSD_REST $BAR_REST)

SWP_INFO=$(free | grep Swap)
SWP_VALUE=$(echo $SWP_INFO | awk '{print $3}')
SWP_VALUE=$(($SWP_VALUE/1000))
SWP_TOTAL=$(echo $SWP_INFO | awk '{print $2}')
SWP_TOTAL=$(($SWP_TOTAL/1000))
SWP_PERCENTAGE=$(((${SWP_VALUE} / $SWP_TOTAL) * 100))
SWP_ROUND=$((SWP_PERCENTAGE - (SWP_PERCENTAGE%ROUNDOFF)))
SWP_REST=$((100-SWP_ROUND))
SWP_BAR=$(generate_bar $SWP_ROUND $BAR_FILL)
SWP_REST_BAR=$(generate_bar $SWP_REST $BAR_REST)


# █▀▀ █▀█ █▄░█ █▀▄ █ ▀█▀ █ █▀█ █▄░█ ▄▀█ █░░   █▀▀ █▀█ █░░ █▀█ █▀█ █▀
# █▄▄ █▄█ █░▀█ █▄▀ █ ░█░ █ █▄█ █░▀█ █▀█ █▄▄   █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
# ==================================================================
# Solid State Drive
if [[ $SSD_PERCENT -lt 80 ]]; then
  COL_SSD=${BLU}
elif [[ $SSD_PERCENT -lt 90 ]]; then
  COL_SSD=${YLO}
else
  COL_SSD=${RED}
fi

# Swap Partition
if [[ $SWP_PERCENTAGE -lt 50 ]]; then
  COL_SWP=${BLU}
elif [[ $SWP_PERCENTAGE -lt 80 ]]; then
  COL_SWP=${YLO}
else
  COL_SWP=${RED}
fi

# Random Access Memory
if [[ $RAM_PERCENT -lt 50 ]]; then
  COL_RAM=${BLU}
elif [[ $RAM_PERCENT -lt 80 ]]; then
  COL_RAM=${YLO}
else
  COL_RAM=${RED}
fi

# Battery
if [[ $BAT_PERCENT -gt 60 ]]; then
  COL_BAT=${BLU}
elif [[ $BAT_PERCENT -gt 30 ]]; then
  COL_BAT=${YLO}
else
  COL_BAT=${RED}
fi

# Battery Status
if [[ $BATTERY_STATUS == 'Charging' ]]; then
  BAT_STATUS_ICO="${YLO}󱐋${R}"
else
  BAT_STATUS_ICO=''
fi


# █▀▀ █ █▄░█ ▄▀█ █░░   █▀▄ ▄▀█ ▀█▀ ▄▀█
# █▀░ █ █░▀█ █▀█ █▄▄   █▄▀ █▀█ ░█░ █▀█
# ====================================

# RAM Value
if [[ $RAM_VALUE -gt 1023 ]]; then
  RAM_VALUE=$(echo $RAM_VALUE | awk '{printf "%.1f GB", $1/1024}')  # Return in GB
else
  RAM_VALUE+=' MB'
fi

# BAT Value with WATTAGE
if [[ $BAT_WATT != '0.0' ]]; then
  BAT_PERCENT="${BAT_PERCENT}% @${BAT_WATT}W"
else
  BAT_PERCENT+="%"
fi

# OS Name
if [[ -f /etc/os-release ]]; then
    OSNAME=$(grep -Po '(?<=^PRETTY_NAME=).*' /etc/os-release | tr -d '"')
elif [[ -f /usr/lib/os-release ]]; then
    OSNAME=$(grep -Po '(?<=^PRETTY_NAME=).*' /usr/lib/os-release | tr -d '"')
else
    OSNAME=$(uname -o)
fi

# Host Device
# vendor=$(cat /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null)
product=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
version=$(cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null)
HOSTDEVICE="${product} ${version}"


# █▀█ █░█ ▀█▀ █▀█ █░█ ▀█▀
# █▄█ █▄█ ░█░ █▀▀ █▄█ ░█░
# =======================
echo " "
echo -e "  ${X}     ${Y}o. ${X}      ${Y} .o${X}     ${R}   ${RED}${ICO}${GRN}${ICO}${YLO}${ICO}${BLU}${ICO}${PNK}${ICO}${CYN}${ICO}${WHT}${ICO}${BLK}${ICO}${R}"
echo -e "  ${X},    ${Y}yyo${X}      ${Y}oyy${X}    ,${R}"
echo -e "  ${X}oNo  ${Y}yyy${X}      ${Y}yyy${X}  oNo${R}   ${U}${H}${USER}${WHT}@${H}${HOSTNAME}${R}"
echo -e "  ${X}oMMNs${Y}yyy${X}      ${Y}yyy${X}sNMMo${R}   ${B}OS:${R} ${OSNAME}"
echo -e "  ${X}oMMMM${Y}yyy${X}      ${Y}yyy${X}MMMMo${R}   ${B}Device:${R} ${HOSTDEVICE}"
echo -e "  ${X}oMMhd${Y}yyy${X}y.  .y${Y}yyy${X}yyMMo${R}   ${B}Datetime:${R} $(date +"${V}%d${R} %b %Y, ${V}%H:%M${R} %a")"
echo -e "  ${X}oMMo ${Y}yyy${X}MMyyMM${Y}yyy${X} oMMo${R}   ${B}Uptime:${R} ${UPTIME}"
echo -e "  ${X}oMMo ${Y}yyy${X}sNMMNo${Y}yyy${X} oMMo${R}"
echo -e "  ${X}oMMo ${Y}yyy${X} '++' ${Y}yyy${X} oMMo${R}   ${U}${H}Device Details:${R}"
echo -e "  ${X}oMMo ${Y}yyy${X}      ${Y}yyy${X} oMMo${R}   ${B}CPU:${R} AMD Ryzen 5 5500U"
echo -e "  ${X}oMMo ${Y}oyy${X}      ${Y}yyo${X} oMMo${R}   ${B}GPU:${R} AMD Radeon RX Vega 7"
echo -e "  ${X}oMMo ${Y} *o${X}      ${Y}o* ${X} oMMo${R}   ${B}SSD:${R} ${COL_SSD}$SSD_BAR${BLK}$SSD_REST_BAR${R} $SSD_PERCENT%${R}"
echo -e "  ${X}oMMo ${Y}   ${X}      ${Y}   ${X} oMMo${R}   ${B}RAM:${R} ${COL_RAM}$RAM_BAR${BLK}$RAM_REST_BAR${R} ${RAM_VALUE}${R}"
echo -e "  ${X}:NMo ${Y}   ${X}      ${Y}   ${X} oMN:${R}   ${B}SWP:${R} ${COL_SWP}$SWP_BAR${BLK}$SWP_REST_BAR${R} ${SWP_VALUE} MB${R}"
echo -e "  ${X}  o+ ${Y}   ${X}      ${Y}   ${X} +o  ${R}   ${B}BAT:${R} ${COL_BAT}$BAT_BAR${BLK}$BAT_REST_BAR${R} $BAT_PERCENT${R} $BAT_STATUS_ICO"

# benchmark_end=$(date +%N)
# benchmark=$(((${benchmark_end:0:-6} - ${benchmark_start:0:-6})))
# echo "${benchmark}ms"
