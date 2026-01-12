# 🍱 TMUX (Terminal Multiplexer)

![TMUX](./.assets/tmux.jpg)

tmux is an open-source terminal multiplexer for Unix-like operating systems. It
allows multiple terminal sessions to be accessed simultaneously in a single
window. It is useful for running more than one command-line program at the same
time. It can also be used to detach processes from their controlling terminals,
allowing remote sessions to remain active without being visible.

## Disadvantages

> Doesn't recognize many ctrl sequences

Most terminal apps when run inside tmux can only recognize the following ctrl chars:

- `Ctrl-A` .. `Ctrl-Z`
- `Ctrl-@` `Ctrl-[` `Ctrl-\` `Ctrl-]` `Ctrl-^` `Ctrl-_`

and they cannot tell the difference between, for example, `Ctrl-i` and `Tab`,
`Ctrl-M` and `Enter`, `Ctr-[` and `Esc`, ... (more details
[here](https://www.leonerd.org.uk/hacks/fixterms/)).

Nvim uses [libtermkey](https://www.leonerd.org.uk/code/libtermkey/) which can
recognize more ctrl sequences but for tmux, `Ctrl-=` is the same as `=` so tmux
just forwards = to nvim.

Which means keybindings in neovim should be made with tmux in mind as well so
that they work when using nvim with tmux.

## TMUX Keybindings

| Keymap  | Description |
| ------- | ----------- |
| C-Space | Prefix Mode |
| v       | Copy Mode   |

## Prefix Mode Keybindings

| Keymap | Description        |
| ------ | ------------------ |
| n      | Next Window        |
| p      | Previous Window    |
| x      | Close Window       |
| hjkl   | Navigate Panes     |
| sv     | Split Vertically   |
| sh     | Split Horizontally |
| t      | Show Time          |
| w      | Window Preview     |

## Copy Mode Keybindings

| Keymap | Description             |
| ------ | ----------------------- |
| v      | Selection               |
| C-v    | Block Selection         |
| H      | Go to start of Line     |
| L      | Go to end of Line       |
| y      | Yank and Exit Copy Mode |
| Esc    | Exit Copy Mode          |
