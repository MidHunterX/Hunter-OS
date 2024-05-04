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
  if command -q bat
    bat $argv --theme base16
  else
    command cat $argv
  end
end

# FZF -> FD
# =========
function fzf
  if command -q fd
    fd $argv
  else
    command fzf $argv
  end
end

