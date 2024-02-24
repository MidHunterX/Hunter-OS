arch.updateBatteryPercent() {
  BATTERY=$(cat /sys/class/power_supply/BAT0/capacity)
}

arch.updateBatteryStatus() {
  BATTERY_STATUS=$(cat /sys/class/power_supply/BAT0/status)
}
