# Hunter OS

## 🌿 Philosophy

**Distro Agnostic**: Designed to be compatible with a wide range of Linux distributions, ensuring workflow features regardless of preferred base.

**Terminal Focused**: The terminal is the heart of this distro, providing CLI/TUI tools and utilities for efficient and streamlined workflows.

**Lightweight, Optimized, and Battery Efficient**: Perfectly engineered to be light on system resources, ensuring smooth performance even on low-powered devices. Every aspect is optimized for maximum efficiency, extending battery life and also have many features at disposal.

**Keyboard Centric Workflow with Vim Style Keybindings**: Promotes a keyboard-centric approach, with Vim-style keybindings deeply integrated into every tools, apps and utilities. This allows to navigate and interact with speed, precision and comfortability.

## 💼 Custom Configurations

| SW Type              | SW Name                                                |
| -------------------- | ------------------------------------------------------ |
| GUI Code Editor      | 🆚 [Code OSS](.config/Code%20-%20OSS/User/)            |
| TUI Code Editor      | 📝 [NeoVim](https://github.com/MidHunterX/HunterX-PDE) |
| Web Browser          | 🦊 [FireFox](.mozilla/)                                |
| Music Visualizer     | 📊 [Cava](.config/cava/)                               |
| Notification Daemon  | 🔔 Dunst                                               |
| Image Viewer         | 🌄 [Feh](.config/feh/)                                 |
| Shell                | 🐟 [Fish](.config/fish/)                               |
| App Launcher         | 📜 [Fuzzel](.config/fuzzel/)                           |
| Wayland Compositor   | 💧 [Hyprland](.config/hypr/)                           |
| Key Remapping Daemon | 🎹 [KeyD](.config/keyd/)                               |
| Terminal Emulator    | 🐱 [Kitty](.config/kitty/)                             |
| Git TUI Frontend     | 😴 [LazyGit](.config/lazygit/)                         |
| Video Player         | 🎬 [Mpv](.config/mpv/)                                 |
| Shell Prompt Engine  | 🚀 [Starship](.config/starship/)                       |
| Terminal Multiplexer | 🍱 [Tmux](.config/tmux/)                               |
| File Manager         | 📁 [ViFM](.config/vifm/)                               |
| Status Bar           | 🍫 [WayBar](.config/waybar/)                           |
| Logout Menu          | 🌳 [Wlogout](.config/wlogout/)                         |
| PDF Backend          | Poppler                                                |
| PDF Frontend         | 📄 [Zathura](.config/zathura/)                         |

## 📦 Prefered Packages

<details>
<summary> 📷 Audio, Video and Image </summary>

### 📢 Audio

| Package Name   | Description                                     | Src    |
| -------------- | ----------------------------------------------- | ------ |
| pipewire       | Audio and Video streaming server                | pacman |
| pipewire-pulse | A/V router & processor - PulseAudio replacement | pacman |
| wireplumber    | PipeWire session/policy manager - wpctl         | pacman |
| pamixer        | CLI Volume Control Tool                         | pacman |
| pavucontrol    | GUI Volume Control Tool                         | pacman |

### 🎬 Video

| Package Name | Description                                        | Src    |
| ------------ | -------------------------------------------------- | ------ |
| ffmpeg       | Super advanced library for handling Audio / Video  | pacman |
| mpv          | Video Player - Minimal and integrates well with WM | pacman |
| handbrake    | GUI Video Transcoder                               | pacman |
| yt-dlp       | Video Downloader                                   | pacman |

### 🌄 Image

| Package Name | Description                          | Src    |
| ------------ | ------------------------------------ | ------ |
| feh          | Image Viewer - Super light weight    | pacman |
| nomacs-git   | Image Viewer - Touch screen friendly | aur    |

</details>

<details>
<summary> 🌐 Network and Security </summary>

### 🌐 Network and Security

| Package Name              | Description                        | Src    |
| ------------------------- | ---------------------------------- | ------ |
| dhcpcd                    | DHCP Client Daemon                 | pacman |
| networkmanager            | CLI Network Manager - nmcli        | pacman |
| nmtui                     | TUI Network Manager - nmtui        | pacman |
| wpa_supplicant            | WLAN Daemon                        | pacman |
| bluez                     | Bluetooth Protocol Daemon          | pacman |
| bluez-utils               | Bluetooth Utilities - bluetoothctl | pacman |
| blueman                   | GUI Bluetooth Manager              | pacman |
| curlftpfs                 | Mount FTP as File System           | pacman |
| android-file-transfer     | Mount Android Device               | pacman |
| keepassxc                 | Password Manager                   | pacman |
| torbrowser-launcher       | Anonnymous Onion Browser           | pacman |
| firefox-developer-edition | Internet Browser                   | pacman |

</details>

<details>
<summary> 📦 Development </summary>

### 📦 Development

| Package Name  | Description                  | Src    |
| ------------- | ---------------------------- | ------ |
| git           | Version control system       | pacman |
| lazygit       | TUI for Git                  | pacman |
| nodejs        | Node Java Script Runtime Env | pacman |
| python        | Python Interpreter           | pacman |
| sqlitebrowser | DB Browser for SQLite        | pacman |

</details>

<details>
<summary> 🌲 Desktop </summary>

### 🌲 Desktop

| Package Name | Description                  | Src    |
| ------------ | ---------------------------- | ------ |
| hyprland     | Wayland compositor           | pacman |
| swww         | Wayland Wallpaper Daemon     | pacman |
| waybar       | Wayland Status Bar           | pacman |
| swayidle     | Wayland Idle Manager         | pacman |
| wtype        | Wayland Keystrokes Emulation | pacman |
| wl-clipboard | Wayland Clipboard Utility    | pacman |
| dunst        | Notification Daemon          | pacman |
| wlogout      | Logout Screen                | aur    |
| keyd         | Key Remapping Daemon         | aur    |

</details>

<details>
<summary> 💻 2-in-1 Laptop Specific </summary>

### 💻 2-in-1 Laptop Specific

| Package Name             | Description                            | Src    |
| ------------------------ | -------------------------------------- | ------ |
| yoga-usage-mode-dkms-git | ACPI driver for Tablet mode detection  | aur    |
| detect-tablet-mode-git   | Tablet mode scripts - watch_tablet     | aur    |
| iio-sensor-proxy         | Accelerometer Sensor Driver            | pacman |
| iio-hyprland-git         | Set Hyprland Orientation automatically | aur    |
| auto-cpufreq             | Dynamic CPU Clock Cycle Frequency      | aur    |
| tlp                      | Laptop Power Optimization              | pacman |

</details>

## System Configs

### Sudoers

/etc/sudoers

```
# Sudo Stuff
Defaults timestamp_type=global      # Activate Sudo across terminals
Defaults timestamp_timeout = 10     # Activate Sudo for 10 minutes
Defaults passwd_timeout = 5         # Sudo prompt timeout after 5 minutes
# Login Stuff
Defaults insults                    # Incorrect Password Easteregg
Defaults pwfeedback                 # Visible Password Feedback
```

### Skip Username

/etc/systemd/system/getty@tty1.service.d/skip-username.conf

```
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -- <username>' --noclear --skip-login - $TERM
```
