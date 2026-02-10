# Testing

| Package               | Desc                                 | pacman |
| --------------------- | ------------------------------------ | ------ |
| mpvc                  | CLI MPV Player                       | aur    |
| helix                 | Visual first Vim like editor         | pacman |
| veracrypt             | Data Encryption                      | pacman |
| aylurs-gtk-shell      | Scaffolding for Astal+Gnim project   | aur    |
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
| speech-dispatcher     | Speech Synthesis (spd-say)           | pacman |
| hyprpolkitagent       | Hyprland GUI Authentication Agent    | pacman |
| docker                | leightweight container runtime       | pacman |
| docker-compose        | build capabilities with BuildKit     | pacman |

Best implementation of transparency:

```
materia-transparent-gtk-theme-git | Transparent GTK | aur
443.09 MiB | Packages (50)
```

- vicinae-bin (App Launcher - C++): Needs constantly running daemon for something we launch rarely. But it's really fast, insanely polished and packed with lot of features.

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

| Software              | Type                                 | pacman |
| --------------------- | ------------------------------------ | ------ |
| ❌ gvfs               | Thunar Automount USB                 | pacman |
| ❌ swaybg             | Wayland Wallpaper Tool               | pacman |
| ❌ libreoffice-fresh  | Office tools                         | pacman |
| ❌ foot               | Terminal Emulator with sixel support | pacman |
| ❌ conky              | Light-weight Rainmeter alternative   | pacman |
| ❌ kmonad             | Keyboard Mapper                      | pacman |
| ❌ input-remapper-bin | Key Remapper                         | aur    |
| ❌ playonlinux        | Wine fork for Windows Games          | aur    |
| ❌ rofi-lbonn-wayland | Rofi Wayland                         | aur    |
| ❌ eww-wayland        | Widgets                              | aur    |
| ❌ stacer-bin         | AIO System Utility SW                | aur    |
| ❌ laptop-mode-tools  | tlp gave better battery performance  | aur    |
| ❌ blesh-git          | TTY BASH readline                    | aur    |
| ❌ wl-screenrec       | Screen recorder for Wayland          | aur    |

- kmonad-bin (Keyboard Remapper): Config style is very convoluted. A code like style is still the best despite the initial learning curve.
- lazysql (SQL TUI Client): Interferes with my lazygit command autocomplete workflow (`laz<TAB>`)
- kew (TUI Music Player): kew's whole design is built around having a home for your music library, and work with simple strings not file paths.
- walker-bin (App Launcher - Rust): Needs elephant, an additional daemon dependency setup to function. Also too slow and clunky.
- sherlock-launcher-bin (App Launcher - Rust): Noticeable milliseconds of delay on startup. Absolutely terrible history search algorithm.
- thunar (XFCE GUI File Browser): Installs many other unwanted and useless dependencies along with it wasting your disk space.
- gazelle-tui (nmtui alt): Too slow.
- emacs-wayland (Text Editor): Very slow and heavy. I'll take neovim instead.

## Rejected but Might Retry Later

- yazi (File Manager): Really great and fast image viewing capability in terminal. Needs heavy rework to be as functional as my vifm config.
- voice2json (Voice and Intent recognition): Didn't figure out to use voice model yet.
- jujutsu (Git compatible D-VCS): Not really compatible with my current workflow relying on branching and selective commits.
- imcat-git (ANSI Image Converter):
- laptop-mode-tools (Laptop Optimization Features):
- bottles-git (Wine prefix manager): Handles prefixes for you but.. needs to find way to work with portable windows games.
- wine (Win32 API Compatibility Layer): Would be great if I can handle prefixes on my own. Needs to invest time.
- kando-bin (Wayland compatible cross platform Fly Pie alt): Still in beta phase.. waiting for it to become mature.
