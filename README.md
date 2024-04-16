# Hunter OS

## 🌿 Philosophy

**Distro Agnostic**: Designed to be compatible with a wide range of Linux distributions, ensuring workflow features regardless of preferred base.

**Terminal Focused**: The terminal is the heart of this project, providing CLI/TUI tools and utilities for efficient and streamlined workflows.

**Lightweight, Optimized, and Battery Efficient**: Perfectly engineered to be light on system resources, ensuring smooth performance even on low-powered devices. Every aspect is optimized for maximum efficiency, extending battery life and also have many features at disposal.

**Keyboard Centric Workflow with Vim Style Keybindings**: Promotes a keyboard-centric approach, with Vim-style keybindings deeply integrated into every tools, apps and utilities. This allows to navigate and interact with speed, precision and comfortability.

**Focus on Flexibility**: Offers multiple pathways to accomplish tasks to choose the method that best suits the workflow at that specific moment in time.

## 🍫 Status Bar (waybar)

Highly customizable Wayland bar for Sway and Wlroots based compositors.

![Waybar](./assets/waybar.png)

## 🌄 Image Viewer (feh)

![feh Image Viewer](./assets/feh.jpg)

feh is a lightweight image viewer aimed mainly at users of command line interfaces. Unlike most graphical image viewers, feh does not have any graphical control elements.

| Keymap      | Description             |
| ----------- | ----------------------- |
| u           | Zoom In                 |
| d           | Zoom Out                |
| s           | Set to Fit Zoom         |
| S           | Set to Default Zoom     |
| j, h, left  | Previous Image          |
| k, l, right | Next Image              |
| f           | Toggle Fullscreen       |
| o           | Toggle EXIF Information |
| i           | View Filename           |
| q, x        | Quit/Close              |

## 🐚 Shell (fish)

fish is a Unix shell with a focus on interactivity and usability. Fish is designed to give the user features by default, rather than by configuration. Fish is considered an exotic shell since it does not adhere to POSIX shell standards, at the discretion of the maintainers.

### Abbreviated Commands

| Command  | Description                                   |
| -------- | --------------------------------------------- |
| yeet     | Remove Packages along with their Dependencies |
| woman    | Yapping all possible Man pages                |
| sayonara | Shutdown Computer                             |
| brs      | Set Brightness                                |
| vos      | Set System Volume                             |
| cls      | Clear Terminal Screen (`CTRL + L`)            |

### Move Terminal Apps to BG and FG

- Press `CTRL + Z` when inside terminal app to move it to Background.
- Press `CTRL + Z` inside terminal prompt to move BG app to Foreground.

![Jobs Icon](./assets/prompt_jobs.png)

The number of background apps will be shown in prompt as shown.

### Auto Complete based on CMD History

- Go to Normal Mode and search using `/`

![fish CMD History](./assets/prompt_hist2.png)

### Better LS and CD navigation

![fish LS CD](./assets/fish_lscd.jpg)

Navigate using ls and cd with much better comfortability.

- Install **lsd** and **bat** for the NerdFont goodness.

### Edit Shell Prompt Input with NeoVim

- Press `Alt + e` on Insert mode to edit shell prompt input inside Neovim

![Fish Edit with Neovim](./assets/fish_editor.jpg)

### Extra Functionalities

- `Alt + e` to edit shell prompt input inside Neovim
- Auto Pair brackets and quotes
- Clean out bad CMD History

## 🚀 Shell Prompt (starship)

Structure: `[ OS > ( Directory | Git Branch ) > Info > Status ]`

### Vim Modes

Insert Mode:

![Insert Mode](./assets/prompt.png)

Normal Mode:

![Normal Mode](./assets/prompt_normal.png)

Visual Mode:

![Visual Mode](./assets/prompt_visual.png)

Replace Mode:

![Replace Mode](./assets/prompt_replace.png)

## 🎹 System Wide Key Remaps (keyd)

Linux lacks a good key remapping solution. In order to achieve satisfactory results a medley of tools need to be employed (e.g xcape, xmodmap) with the end result often being tethered to a specified environment (X11). keyd attempts to solve this problem by providing a flexible system wide daemon which remaps keys using kernel level input primitives (evdev, uinput).

| Remap            | Output Key             |
| ---------------- | ---------------------- |
| Space + h        | Left                   |
| Space + j        | Down                   |
| Space + k        | Up                     |
| Space + l        | Right                  |
| Space + w        | Move One Word Forward  |
| Space + b        | Move One Word Backward |
| f j              | Esc                    |
| CapsLock (Click) | Esc                    |
| CapsLock (Press) | Ctrl                   |

## 🐱 Terminal Emulator (kitty)

kitty is a free and open-source GPU-accelerated terminal emulator for Linux and macOS focused on performance and features. kitty is written in a mix of C and Python programming languages. It provides GPU support. kitty shares its name with another program — KiTTY — a fork of PuTTY for Microsoft Windows.

| Keymap                   | Description                    |
| ------------------------ | ------------------------------ |
| Alt + N                  | Send Terminal to Neovim Buffer |
| Ctrl + Shift + N         | New Tab                        |
| Ctrl + Shift + J         | Scroll Line Down               |
| Ctrl + Shift + K         | Scroll Line Up                 |
| Ctrl + Shift + D         | Scroll Page Down               |
| Ctrl + Shift + U         | Scroll Page Up                 |
| Ctrl + Shift + Backspace | Clear One Whole Word           |

### Move Terminal Buffer into Neovim Temporarily

- Press `Alt + n` to send a copy of terminal buffer into Neovim.
- Then it can be used for scrollback, jumping quickly around and copying text.
- To exit, either press `q` or `i`

![Kitty Neovim Integration](./assets/kitty_nvim.jpg)

## 🎬 Video Player (mpv)

mpv is free and open-source media player software based on MPlayer, mplayer2 and FFmpeg. It runs on several operating systems, including Unix-like operating systems (Linux, BSD-based, macOS) and Microsoft Windows. It is cross-platform, running on ARM, PowerPC, x86/IA-32, x86-64, and MIPS architecture.

| Keymap | Description          | Keymap | Description             |
| ------ | -------------------- | ------ | ----------------------- |
| d      | Volume Down by 2     | k      | Seek +5 Video Frames    |
| u      | Volume Up by 2       | J      | Seek One Frame Backward |
| x      | Close                | K      | Seek One Frame Forward  |
| h      | Seek -10s            | i      | Video Information       |
| l      | Seek +10s            | c      | Cycle Through Subtitles |
| H      | Seek -30s            | f      | Fullscreen              |
| L      | Seek +30s            | m      | Mute Volume             |
| j      | Seek -5 Video Frames | Return | Show Progress           |

## 📁 File Manager (vifm)

![VIFM](./assets/vifm.jpg)

Vifm is a file manager with curses interface, which provides Vim-like environment for managing objects within file systems, extended with some useful ideas from mutt. If you use vi, Vifm gives you complete keyboard control over your files without having to learn a new set of commands.

| Keymap   | Description             | Keymap   | Description              |
| -------- | ----------------------- | -------- | ------------------------ |
| Ctrl + f | Fuzzy Find Files        | Ctrl + d | Scroll Page Down         |
| ?        | Fuzzy Find Files        | u        | Undo                     |
| /        | Fast Navigation Mode    | U        | Redo                     |
| Ctrl + o | Go Backward History     | H        | Move to Left View/Split  |
| Ctrl + i | Go Forward History      | L        | Move to Right View/Split |
| o        | Open With               | W        | Scroll through views     |
| t        | touch File              | Ctrl + n | New Tab                  |
| M        | mkdir Directory         | Ctrl + t | New Tab                  |
| i        | Execute Files/Directory | Alt + h  | Switch to Tab on Left    |
| a        | Rename Filename         | Alt + l  | Switch to Tab on Right   |
| A        | Rename Filename + Ext   | ' h      | Go to Home/              |
| cw       | Rename Filename         | ' d      | Go to Downloads/         |
| cW       | Rename Filename + Ext   | ' c      | Go to .config/           |
| Ctrl + u | Scroll Page Up          | x, q     | Close/Quit               |

### Bulk-Rename Multiple Filenames in Neovim

- Press `a` or `cw` in Visual Mode to multi-rename files/dirs
- Save and Exit Neovim buffer to save changes

![VIFM Bulk Rename](./assets/vifm_rename.jpg)

### Extra Features

- File View Syntax Highlighting using **highlight**
- **NerdFont** icons for Files and Directories
- Added support for:
  - SQLite Browser for DB Files
  - Zathura PDF
  - Feh Image Viewer
  - Kitten Terminal Image Printing
  - 7zip archive extration
- .git Dir shows git status output
- Directory list with ls colors

### Default Functionalities

- The most useful default functionality is `s` to drop into shell from currently opened directory
- `w` to toggle file viewer
