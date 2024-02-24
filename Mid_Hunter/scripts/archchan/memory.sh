archchan.batteryCapacity() {
  BATTERY=$(cat /sys/class/power_supply/BAT0/capacity)
}

archchan.batteryStatus() {
  BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status)
}
