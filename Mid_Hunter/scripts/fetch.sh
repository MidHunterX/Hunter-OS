#!/bin/bash

BLK='\033[1;30m'
RED='\033[1;31m'
GRN='\033[1;32m'
YLO='\033[1;33m'
BLU='\033[1;34m'
PNK='\033[1;35m'
CYN='\033[1;36m'
WHT='\033[1;37m'
BLKD='\033[1;30m'

DEF='\033[0;39m'
RESET='\033[0;0m'

R=${RESET}

X=${BLU} # Accent 1
Y=${YLO} # Accent 2

H=${BLU} # Heading
L=${WHT} # Line
B=${GRN} # Bold
V=${YLO} # Values

uptime=$(uptime -p | awk -F'( |,)+' '{print $2,$3,$4,$5}')

echo " "
echo -e "  ${X}     ${Y}o. ${X}      ${Y} .o${X}     ${R}   ${H}midhunter${R}@${H}Flex-5"
echo -e "  ${X},    ${Y}yyo${X}      ${Y}oyy${X}    ,${R}   ${L}-----------------"
echo -e "  ${X}oNo  ${Y}yyy${X}      ${Y}yyy${X}  oNo${R}   ${B}OS:${R} Arch Linux"
echo -e "  ${X}oMMNs${Y}yyy${X}      ${Y}yyy${X}sNMMo${R}   ${B}Host:${R} 82HU IdeaPad Flex 5 14ALC05"
echo -e "  ${X}oMMMM${Y}yyy${X}      ${Y}yyy${X}MMMMo${R}   ${B}Resolution:${R} 1920x1080"
echo -e "  ${X}oMMhd${Y}yyy${X}y.  .y${Y}yyy${X}yyMMo${R}   ${B}Uptime:${R} ${uptime}"
echo -e "  ${X}oMMo ${Y}yyy${X}MMyyMM${Y}yyy${X} oMMo${R}"
echo -e "  ${X}oMMo ${Y}yyy${X}sNMMNo${Y}yyy${X} oMMo${R}   ${H}UserBenchmarks:${R}   Game: ${V}20%${R},   Desk: ${V}86%${R},   Work: ${V}18%${R}"
echo -e "  ${X}oMMo ${Y}yyy${X} '++' ${Y}yyy${X} oMMo${R}   ${L}--------------- "
echo -e "  ${X}oMMo ${Y}yyy${X}      ${Y}yyy${X} oMMo${R}   ${B}CPU:${R} AMD Ryzen 5 5500U - ${V}86%"
echo -e "  ${X}oMMo ${Y}oyy${X}      ${Y}yyo${X} oMMo${R}   ${B}GPU:${R} AMD Radeon RX Vega 7 - ${V}14.4%"
echo -e "  ${X}oMMo ${Y} *o${X}      ${Y}o* ${X} oMMo${R}   ${B}SSD:${R} Micron MTFDHBA512QFD 512GB - ${V}184.5%"
echo -e "  ${X}oMMo ${Y}   ${X}      ${Y}   ${X} oMMo${R}   ${B}RAM:${R} Hynix HMA851S6DJR6N-XN 2x4GB - ${V}71.1%"
echo -e "  ${X}:NMo ${Y}   ${X}      ${Y}   ${X} oMN:${R}   ${B}MBD:${R} LNVNB161216"
echo -e "  ${X}  o+ ${Y}   ${X}      ${Y}   ${X} +o  ${R}"
echo -e "                           ${RED}   ${GRN}   ${YLO}   ${BLU}   ${PNK}   ${CYN}   ${WHT}   ${BLK}   ${R}"
