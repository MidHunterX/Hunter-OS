# Greeting
set fish_greeting ""

if status is-interactive
  # Semantic abbreviations
  abbr -a -g fetch 'fastfetch'
  abbr -a -g gitfetch 'onefetch'

  # █▀█ ▄▀█ ▀█▀ █░█ █▀
  # █▀▀ █▀█ ░█░ █▀█ ▄█
  # ==================
  # Local bin
  if test -d $HOME/.local/bin
    set -x PATH $HOME/.local/bin $PATH
  end

  # Environment Variables
  if test -f $XDG_CONFIG_HOME/fish/env.fish
    source $XDG_CONFIG_HOME/fish/env.fish
  end

  # ▄▀█ █▄▄ █▄▄ █▀█   ▄▀█ █▄░█ █▀▄   ▄▀█ █░░ █ ▄▀█ █▀
  # █▀█ █▄█ █▄█ █▀▄   █▀█ █░▀█ █▄▀   █▀█ █▄▄ █ █▀█ ▄█
  # =================================================
  # User abbreviations
  abbr -a -g sayonara 'shutdown now'  # Epic way to Shutdown
  abbr -a -g cls 'clear'  # Clear Screen
  abbr -a -g yeet 'sudo pacman -Rns'  # Remove packages with dependencies
  abbr -a -g mid 'nvim'  # Neovim
  abbr -a -g brs 'bash ~/Mid_Hunter/scripts/set_brightness.sh'  # Brightness
  abbr -a -g vos 'bash ~/Mid_Hunter/scripts/set_volume.sh'  # Volume
  abbr -a -g woman 'man -k . | fzf | awk \'{print $1}\' | xargs man'

  alias arch 'bash ~/Mid_Hunter/scripts/archchan/get_command-list.sh'
  alias vim 'nvim'


  # function format_duration
  #   set ms $CMD_DURATION
  #   set x (math --scale=0 $ms / 1000)
  #   set seconds (math --scale=0 $x % 60)
  #   set x (math --scale=0 $x / 60)
  #   set minutes (math --scale=0 $x % 60)
  #   set x (math --scale=0 $x / 60)
  #   set hours (math --scale=0 $x % 24)
  #   set result ""
  #   if test $hours -gt 0
  #     set result "$result$hours"h
  #   end
  #   if test $minutes -gt 0
  #     set result "$result$minutes"m
  #   end
  #   if test $seconds -gt 0 -o (not test -n "$result")
  #     set result "$result$seconds"s
  #   end
  #   echo $result
  # end


  # LS_COLORS
  source ~/.config/fish/ls_colors.fish
  # Better Alternatives
  source ~/.config/fish/better_alternatives.fish

  # Starship prompt
  starship init fish | source
  set -x STARSHIP_CONFIG $HOME/.config/starship/starship.toml

  # Starship transient prompt
  function starship_transient_prompt_func
    set BLKFG '\033[1;30m'
    set GRNFG '\033[1;32m'
    set YLOFG '\033[1;33m'
    set WHTFG '\033[1;37m'

    set BLKBG '\033[1;40m'
    set GRNBG '\033[1;42m'
    set YLOBG '\033[1;43m'
    set WHTBG '\033[1;47m'

    set BOLD '\033[4m'
    set RESET '\033[0;0m'
    set PROMPT ""

    # BUBBLE
    set PROMPT (string join '' $PROMPT "$RESET$YLOFG")
    set PROMPT (string join '' $PROMPT "$YLOBG$BLKFG $(date +%H:%M) ")
    set PROMPT (string join '' $PROMPT "$RESET$YLOFG")

    echo -n -e "\n$PROMPT$RESET "
  end
  enable_transience

  # Starship <-> VIFM Integration Behavior
  if test -n "$VIFM_MODE"
    function vifm_ctrl_d
      # only typing command for triggering transient prompt with enter key
      commandline -r "exit"
    end
    bind --mode insert \cd vifm_ctrl_d
  end


  # █▀▀ █░█ █▀ ▀█▀ █▀█ █▀▄▀█   █▀▀ █▀█ █░░ █▀█ █▀█ █▀
  # █▄▄ █▄█ ▄█ ░█░ █▄█ █░▀░█   █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
  # =================================================
  # Custom Completion Colors
  set fish_pager_color_background --background=black
  set fish_pager_color_secondary_background --background=brblack
  set fish_pager_color_progress white  # the progress bar at the bottom left
  set fish_pager_color_prefix blue  # already typed tab completion
  set fish_pager_color_completion white  # rest of the tab completion
  set fish_pager_color_description yellow  # tab completion (description)
  set fish_color_autosuggestion 7e7e7e

  # Set the cursor shapes for the different vi modes.
  set fish_cursor_default     block      blink
  set fish_cursor_insert      line       blink
  set fish_cursor_replace_one underscore blink
  set fish_cursor_visual      block



  # █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
  # █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
  # ========================================
  bind --mode default U redo

  # Move to 0 and $ with H and L
  for mode in default visual
    bind --mode $mode H 'commandline -f beginning-of-line'
    bind --mode $mode L 'commandline -f end-of-line'
  end

  # Ctrl-Z fg command
  bind --mode insert \cz 'fg 2>/dev/null; commandline -f repaint'



  # █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
  # █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█
  # ==================================
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
    builtin cd "$dst"
  end

end

# zoxide
if command -q zoxide
  zoxide init fish --cmd=z | source
end
