# 🐱 KITTY (Terminal Emulator)

kitty is a free and open-source GPU-accelerated terminal emulator for Linux and macOS focused on performance and features. kitty is written in a mix of C and Python programming languages. It provides GPU support. kitty shares its name with another program — KiTTY — a fork of PuTTY for Microsoft Windows.

## Kitty Keybindings

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

![Kitty Neovim Integration](./.assets/kitty_nvim.jpg)
