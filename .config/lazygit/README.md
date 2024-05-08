# LazyGit (git TUI Frontend)

![LazyGit](./.assets/lazygit.jpg)

A simple terminal UI for git commands

## LazyGit Keybindings

### General Keybindings

| Keymap   | Description        |
| -------- | ------------------ |
| H J K L  | Movement Keys      |
| CTRL + D | Scroll Down        |
| CTRL + U | Scroll Up          |
| V        | Visual Mode        |
| /        | Search             |
| Z        | Undo               |
| CTRL + Z | Redo               |
| Q        | Quit               |
| X        | Exit               |
| +/-      | Cycle Window Sizes |

### Files View Keybindings

| Keymap | Description     |
| ------ | --------------- |
| A      | Git add .       |
| I      | gitignore file  |
| E      | gitexclude file |

### Branches View Keybindings

| Keymap | Description                   |
| ------ | ----------------------------- |
| W      | Create Worktree from a Commit |

### Commits View Keybindings

| Keymap    | Description                                          |
| --------- | ---------------------------------------------------- |
| I         | Interactive Rebase                                   |
| S         | Squash (Combine Multiple Commits)                    |
| F         | Fixup (Combine Commits with Previous Commit Message) |
| D         | Drop (Remove Commit from Commit History)             |
| E         | Edit (Pause Rebase and make changes to a Commit)     |
| CTRL + I  | Move Up                                              |
| CTRL + J  | Move Down                                            |
| SHIFT + C | Cherry Pick Copy Commit                              |
| SHIFT + V | Cherry Pick Paste Commit                             |
| B         | Mark Commit as good/bad for git bisect               |
| SHIFT + D | Nuke the working tree                                |
| SHIFT + A | Ammend Commit (Make Changes to the last Commit)      |
