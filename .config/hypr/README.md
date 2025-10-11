# 💧 Hyprland (Wayland Compositor)

![Hyprland](./.assets/hypr.jpg)

Hyprland is a dynamic tiling Wayland compositor based on wlroots that doesn't sacrifice on its looks.

It provides the latest Wayland features, is highly customizable, has all the eyecandy, the most powerful plugins, easy IPC, much more QoL stuff than other wlr-based compositors.

## Hyprland Keybindings

### Vim Style Modal Keybindings

Press `SUPER + E` to enter **Execute** Mode and activate the following keys

| Keymap    | Description                                    |
| --------- | ---------------------------------------------- |
| F         | **F**irefox (Default Profile)                  |
| E         | **E**xperiment Firefox Profile                 |
| K         | **K**itty Terminal Emulator                    |
| W         | **W**aybar Refresh                             |
| SHIFT + W | **W**aybar Toggle                              |
| B         | **B**rightness Script                          |
| V         | **V**olume Script                              |
| P         | **P**rint Screen with Tesseract OCR Extraction |
| ESC       | Disable Execute Mode                           |

Press `SUPER + C` to enter **Cursor** Mode and activate the following keys

| Keymap          | Description                |
| --------------- | -------------------------- |
| F               | Vim like Find mode         |
| H,J,K,L         | Move cursor                |
| SHIFT + H,J,K,L | Move cursor faster         |
| I               | Left Click (Inside click)  |
| O               | Right Click (Outside menu) |
| U               | Scroll Up                  |
| D               | Scroll Down                |
| W               | Scroll Right               |
| B               | Scroll Left                |
| ESC             | Exit Cursor Mode           |

Press `SUPER + T` to enter window **Transformation** Mode and activate the following keys

| Keymap          | Description   |
| --------------- | ------------- |
| H,J,K,L         | Focus window  |
| SHIFT + H,J,K,L | Move window   |
| CTRL + H,J,K,L  | Resize window |
| ESC             | Exit Mode     |

### Windows Style Keybindings

| Keymap           | Description             |
| ---------------- | ----------------------- |
| ALT + TAB        | Move through workspaces |
| SUPER + PERIOD   | Emoji menu              |
| CTRL + ESC       | htop Process Manager    |
| CTRL + ALT + DEL | htop Process Manager    |

### Window Management Keybindings

| Keymap              | Description                 |
| ------------------- | --------------------------- |
| SUPER + X           | Close window                |
| SUPER + F           | Toggle Fullscreen window    |
| SUPER + M           | Toggle split                |
| SUPER + V           | Toggle floating window mode |
| SUPER + S           | Toggle special workspace    |
| SUPER + SHIFT + S   | Move to special workspace   |
| SUPER + TAB         | Move forward workspaces     |
| SUPER + SHIFT + TAB | Move forward workspaces     |

### Focus and Switch Keybindings

| Keymap                | Description                |
| --------------------- | -------------------------- |
| SUPER + H             | Focus left split           |
| SUPER + J             | Focus lower split          |
| SUPER + K             | Focus upper split          |
| SUPER + L             | Focus right split          |
| SUPER + SHIFT + H     | Move window to left split  |
| SUPER + SHIFT + J     | Move window to lower split |
| SUPER + SHIFT + K     | Move window to upper split |
| SUPER + SHIFT + L     | Move window to right split |
| SUPER + U             | Focus first workspace      |
| SUPER + I             | Focus second workspace     |
| SUPER + O             | Focus third workspace      |
| SUPER + (1-9)         | Focus specific workspace   |
| SUPER + SHIFT + (1-9) | Move to specific workspace |

### Execution Keybindings

| Keymap            | Description                                          |
| ----------------- | ---------------------------------------------------- |
| SUPER + P         | Take screenshot and save to Pictures                 |
| SUPER + SHIFT + P | Take screenshot with Selection and copy to clipboard |
| SUPER + B         | Logout Menu                                          |
| SUPER + SHIFT + B | Kill Hyprland                                        |

## Default Features:

- Eyecandy Customization: gradient borders, blur, animations, shadows etc.
- Custom bezier curves for the best animations
- Powerful plugin support and Built-in plugin manager
- Tearing support for better gaming performance
- Not afraid to provide bleeding-edge features
- Config reloaded instantly upon saving
- Fully dynamic workspaces
- Two built-in layouts and more available as plugins
- Uses forked wlroots with QoL patches
- Global keybinds passed to your apps of choice
- Tiling/pseudotiling/floating/fullscreen windows
- Special workspaces (scratchpads)
- Window groups (tabbed mode)
- Powerful window/monitor/layer rules
- Socket-based IPC
- Native IME and Input Panels Support
