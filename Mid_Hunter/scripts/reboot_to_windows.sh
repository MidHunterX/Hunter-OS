# Reboot directly to Windows
reboot_to_windows (){
  # eg: 'Windows Boot Manager (on /dev/nvme0n1p1)'
  windows_title=$(sudo grep -i windows /boot/grub/grub.cfg | cut -d "'" -f 2)
  sudo grub-reboot "$windows_title"
  sudo reboot
}
reboot_to_windows
