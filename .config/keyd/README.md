# 🎹 KEYD (System Wide Key Remapping Daemon)

Linux lacks a good key remapping solution. In order to achieve satisfactory results a medley of tools need to be employed (e.g xcape, xmodmap) with the end result often being tethered to a specified environment (X11). keyd attempts to solve this problem by providing a flexible system wide daemon which remaps keys using kernel level input primitives (evdev, uinput).

## KeyD Keybindings

| Remap            | Output Key             |
| ---------------- | ---------------------- |
| Space + h        | Left                   |
| Space + j        | Down                   |
| Space + k        | Up                     |
| Space + l        | Right                  |
| Space + e        | Move to End of Word    |
| Space + b        | Move One Word Backward |
| Space + u        | Move to Front of Line  |
| Space + d        | Move to End of Line    |
| f j              | Esc                    |
| CapsLock (Click) | Esc                    |
| CapsLock (Press) | Ctrl                   |
