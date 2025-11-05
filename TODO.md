# Testing

| Package               | Desc                                 | pacman |
| --------------------- | ------------------------------------ | ------ |
| veracrypt             | Data Encryption                      | pacman |
| git-fame              | git stats                            | aur    |
| ⭐ git-filter-repo    | Filter git repos based on regex      | pacman |
| tokei                 | Code Stats - rust alt to cloc        | pacman |
| swayimg               | Image Viewer                         | pacman |
| 🔥 hellwal            | Color Palette Generator              | aur    |
| matugen-bin           | Material You Color Generator         | aur    |
| systemd-manager-tui   | systemctl alternative                | aur    |
| systemctl-tui         | systemctl alternative                | pacman |
| ⭐ optipng            | PNG Optimizer                        | pacman |
| ⭐ termscp            | Terminal File Transfer               | aur    |
| ⭐ tgpt               | CLI AI Chatbot                       | aur    |
| posting               | TUI HTTP Client                      | aur    |
| nap-bin               | TUI Code Snippet Manager             | aur    |
| atac                  | A Terminal API Client                | aur    |
| opencode-ai-bin       | TUI AI Agent                         | aur    |
| lua                   | Lua Compiler                         | pacman |
| qemu-full             | Machine emulator for KVM Hypervisor  | pacman |
| sc-im                 | Spreadsheet program based on SC      | aur    |
| bottom                | Top with much more stats             | pacman |
| pacman-contrib        | For paccache                         | pacman |
| imagemagick           | Image transcoder / converter         | pacman |
| jp2a                  | Image to ASCII Converter             | pacman |
| ascii-image-converter | ASCII Image Converter                | aur    |
| ocrmypdf              | PDF to OCR                           | aur    |
| powerstat             | ACPI Power Consumption Monitoring    | aur    |
| docker                | Container                            | pacman |
| acpid                 | ACPI Daemon                          | pacman |
| ffmpegthumbnailer     | Video thumbnailer                    | pacman |
| nap-bin               | Snippet Manager                      | aur    |
| jamesdsp              | Audio Effect Preprocessor (Pipewire) | aur    |
| easyeffects           | Audio Equalizer                      | pacman |

Best implementation of transparency:
```
materia-transparent-gtk-theme-git | Transparent GTK | aur
443.09 MiB | Packages (50)
```

---

# Wish List

- fix home dot file pollution [✅ XDG Specification Enforcing]
- touch screen gestures [HyprGrass]
- trackpad gestures
- loudness equalization - Dynamic range compression (pulseaudio)
- easyeffects (pipewire) + LoudnessEqualizer.json preset
- bash/zsh auto completion, syntax highlighting
- Fly Pie for wlroots Compositor

## Flex-5 ALC05 Specific

| Type      | Software (pacman)  |
| --------- | ------------------ |
| Pen Input | input-wacom (Xorg) |

| Type            | Software (aur) |
| --------------- | -------------- |
| Finance Manager | moneymanagerex |

---

# To test

| Type                                | Software       |
| ----------------------------------- | -------------- |
| LD_PRELOAD hack for .config         | libetc         |
| Mastodon Client                     | tut            |
| Procedural Motion Design Tool       | motion canvas  |
| Game Launcher                       | playnite       |
| Network Mapping                     | nmap           |
| Download Manager (HTTP,FTP,Torrent) | motrix         |
| Video Recorder                      | OBS Studio     |
| Video Editor                        | kdenlive       |
| Lock Screen                         | swaylock       |
| Audio Workstation GUI               | qjackctl       |
| Local Syncing                       | syncthing      |
| Touch Screen Gestures               | hyprgrass      |
| SSH Server                          | openssh-server |
| Wayland Session Lock                | swaylock       |

| Package             | Desc                               | pacman |
| ------------------- | ---------------------------------- | ------ |
| lutris              | Wine manager for Windows Games     | pacman |
| nftables, firewalld | Manages netfilter firewall tables  | pacman |
| hyprgrass           | Touch Gesture support for Hyprland | aur    |
| stirling-pdf-bin    | PDF viewer                         | aur    |
| ❌ wluma            | Auto Brightness preference system  | aur    |
| ❌ lazysql          | SQL TUI Client                     | aur    |
| ❌ walker           | Fuzzel Alternative                 | aur    |

waydroid
portmaster

NOTE: easyeffects simple alternative: JamesDSP

easyeffects LoudnessEqualizer preset:
git clone https://github.com/Digitalone1/EasyEffects-Presets
Copy a preset into `~/.config/easyeffects/output`
or download many IEM profiles from [AutoEQ](https://autoeq.app/)

---

```
| brightnessctl     | Brightness Control Utility            | pacman

[discrete]
==== 💡 Brightness
`brillo` is one of the best made brightness control tool. It supports the following features on top of brightnessctl like features:
* Smooth transitions
* Automatic best controller detection
* Set brightness on different controllers like backlight and keyboard

All these cool features but, it's **not actively maintained**. Currently it's in a broken state due to a recent "rounding" update and there's not enough people using it to report the bug... There's not even a place to report the bug. Therefore I choose `brightnessctl`. It doesn't have those cool transitions like brillo but at-least it's reliable. Tools should always be reliable.
```

---

```
| obs-studio   | Open Broadcaster Software                          | pacman

[discrete]
==== Screen Sharing
For screen sharing you mainly need an xdg-desktop-portal for your wl-roots based WM. Then for virtual camera support on `obs-studio` install `v4l2loopback-dkms` package. OBS should load the kernel module by itself.
If you haven't set up sudo for GUI, OBS will crash upon starting virtual camera. If that's the case, you can load v4l2loopback kernel module with:
[source,bash]
----
sudo modprobe v4l2loopback
----
```

---

# Rejected

| Software                 | Type                                 | pacman |
| ------------------------ | ------------------------------------ | ------ |
| yazi                     | File Manager                         | pacman |
| voice2json               | Voice and Intent recognition         | aur    |
| texlive-latexrecommended | LaTeX (latex, pdflatex)              | pacman |
| jujutsu                  | Git compatible D-VCS                 | aur    |
| imcat-git                | ANSI Image Converter                 | aur    |
| laptop-mode-tools        | Laptop Optimization Features         | aur    |
| bottles-git              | Wine prefix manager                  | aur    |
| wine                     | Win32 API Compatibility Layer        | pacman |
| ❌ gazelle-tui           | nmtui alt - too slow                 | aur    |
| ❌ walker-bin            | App Launcher too slow and clunky     | aur    |
| ❌ emacs-wayland         | Emacs Text Editor                    | pacman |
| ❌ gvfs                  | Thunar Automount USB                 | pacman |
| ❌ swaybg                | Wayland Wallpaper Tool               | pacman |
| ❌ pavucontrol           | GUI Volume Control Tool              | pacman |
| ❌ libreoffice-fresh     | Office tools                         | pacman |
| ❌ thunar                | XFCE GUI File Browser                | pacman |
| ❌ foot                  | Terminal Emulator with sixel support | pacman |
| ❌ conky                 | Light-weight Rainmeter alternative   | pacman |
| ❌ kmonad                | Keyboard Mapper                      | pacman |
| ❌ input-remapper-bin    | Key Remapper                         | aur    |
| ❌ playonlinux           | Wine fork for Windows Games          | aur    |
| ❌ rofi-lbonn-wayland    | Rofi Wayland                         | aur    |
| ❌ eww-wayland           | Widgets                              | aur    |
| ❌ stacer-bin            | AIO System Utility SW                | aur    |
| ❌ kmonad-bin            | Advanced Keyboard Remapper           | aur    |
| ❌ kando-bin             | Cross Platform Fly Pie               | aur    |
| ❌ laptop-mode-tools     | tlp gave better battery performance  | aur    |
| ❌ blesh-git             | TTY BASH readline                    | aur    |
| ❌ wl-screenrec          | Screen recorder for Wayland          | aur    |
