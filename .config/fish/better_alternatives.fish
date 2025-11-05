# GIT -> LAZYGIT
# ==============
function git
    if test -n "$argv"
        command git $argv
        return
    end

    if command -q lazygit
        lazygit
    end
end

# LS -> LSD
# =========
function ls
    if command -q lsd
        lsd $argv --group-directories-first
    else
        command ls $argv
    end
end

# CD -> CD & LS
# =============
function cd
    builtin cd $argv
    ls
end

# CAT -> BAT
# ==========
function cat
    # if more than one arg OR stdin is not a tty (piped), fallback to cat
    if test (count $argv) -gt 1 -o ! -t 0
        command cat $argv
    else
        if command -q bat
            bat $argv --theme base16
        else
            command cat $argv
        end
    end
end

# FIND -> FD
# =========
function find
    if command -q fd
        fd $argv
    else
        command find $argv
    end
end
