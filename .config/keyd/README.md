# 🎹 KEYD (System Wide Key Remapping Daemon)

Linux lacks a good key remapping solution. In order to achieve satisfactory
results a medley of tools need to be employed (e.g xcape, xmodmap) with the end
result often being tethered to a specified environment (X11). keyd attempts to
solve this problem by providing a flexible system wide daemon which remaps keys
using kernel level input primitives (evdev, uinput).

## 🏠 Home Row Mods (GCAS)

Homerow modifiers are activated by overloading the specific key assigned to it.

| Key | Output Key |
| --- | ---------- |
| a   | Meta       |
| s   | Ctrl       |
| d   | Alt        |
| f   | Shift      |
| j   | Shift      |
| k   | Alt        |
| l   | Ctrl       |
| ;   | Meta       |

- `Shift` is assigned to `Index finger` as it's the most used key & finger.
- `Alt` is assigned to `Middle finger` because it's the least used key
  assigned to the most dangerous key 'D'.
- `Ctrl` is assigned to `Ring finger` as it's the next strongest finger other
  than Middle finger. Not only that, Ring finger is the most used finger in
  combination with Ctrl.
- `Meta` is assigned to `Pinkie` due to familiarity (because the same finger is
  used to activate that key otherwise).

## 🚀 Space Layer

Space layer is activated by overloading space key. Then press the keys below to
activate space layer remaps.

| Key | Output Key             |
| --- | ---------------------- |
| h   | Left                   |
| j   | Down                   |
| k   | Up                     |
| l   | Right                  |
| e   | Move to End of Word    |
| b   | Move One Word Backward |
| u   | Move to Front of Line  |
| d   | Move to End of Line    |

## 🎹 KeyD Keybindings

| Remap            | Output Key |
| ---------------- | ---------- |
| f j              | Esc        |
| CapsLock (Click) | Esc        |
| CapsLock (Press) | Ctrl       |
