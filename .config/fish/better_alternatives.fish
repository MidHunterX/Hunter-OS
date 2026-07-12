# Semantic: FTP
# =================
function ftp
    if command -q termscp
        termscp $argv
    else
        echo "No ftp client found"
    end
end

# Semantic: WIFI
# =================
function wifi
    if test -n "$argv"
        command wifi $argv
        return
    end
    if command -q wlctl
        wlctl
    else if command -q nmtui
        nmtui
    else
        echo "No wifi client found"
    end
end

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
