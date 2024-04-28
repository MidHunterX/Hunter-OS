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
