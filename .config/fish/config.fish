# Greeting
set fish_greeting ""

# Commands to run in interactive sessions can go here
if status is-interactive

# User abbreviations
  abbr -a -g sayonara 'shutdown now'  # Epic way to Shutdown
  abbr -a -g cls 'clear'  # Clear Screen
  abbr -a -g yeet 'sudo pacman -Rns'  # Remove packages with dependencies
  abbr -a -g mid 'nvim'  # Neovim
  abbr -a -g brs 'bash ~/Mid_Hunter/scripts/set_brightness.sh'  # Brightness
  abbr -a -g vos 'bash ~/Mid_Hunter/scripts/set_volume.sh'  # Volume

  # Starship prompt
  starship init fish | source
  set -x STARSHIP_CONFIG $HOME/.config/starship/starship.toml

  # Suggestion Background
  set fish_pager_color_background --background=black
  set fish_pager_color_secondary_background --background=black

  # Vi mode with default Emacs keybindings
  function fish_hybrid_key_bindings --description \
    "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
      fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
  end
  set -g fish_key_bindings fish_hybrid_key_bindings

  # VIFM CD Function
  function vicd
    set dst "$(command vifm --choose-dir - $argv[2..-1])"
    if [ -z "$dst" ]; 
      echo 'Directory picking cancelled/failed'
      return 1
    end
    cd "$dst"
  end

end

