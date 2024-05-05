# 🎹 KEYD (System Wide Key Remapping Daemon)

Linux lacks a good key remapping solution. In order to achieve satisfactory
results a medley of tools need to be employed (e.g xcape, xmodmap) with the end
result often being tethered to a specified environment (X11). keyd attempts to
solve this problem by providing a flexible system wide daemon which remaps keys
using kernel level input primitives (evdev, uinput).

## Remapping Philosophy
The most used action is assigned to the most powerful finger; the index finger.
Second most used action is assigned to middle finger, then ring finger and so
on. Not only actions but any numerical order are also assigned in this way.
For e.g. 1 to Index, 2 to Middle, 3 to Ring and 4 to Pinkie.
Ohh... and combined with Vim style keybindings btw ;).

## 🏠 Homerow Mods

Homerow modifiers are activated by overloading the specific key assigned to it.

| Key | Output Key |
| --- | ---------- |
| a   | Meta       |
| s   | Alt        |
| d   | Ctrl       |
| f   | Shift      |
| j   | Shift      |
| k   | Ctrl       |
| l   | Alt        |
| ;   | Meta       |

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
