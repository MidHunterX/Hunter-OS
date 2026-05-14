local colors = require("colors.init")

-- █░░ ▄▀█ █▄█ █▀▀ █▀█   █▀█ █░█ █░░ █▀▀ █▀
-- █▄▄ █▀█ ░█░ ██▄ █▀▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

hl.layer_rule({
  name = "launcher",
  match = { namespace = "launcher" },
  blur = true,
  xray = true
})

hl.layer_rule({
  name = "wlogout",
  match = { namespace = "logout_dialog" },
  blur = true,
  xray = false
})

-- Disable blur for everything except
-- windowrule = match:class negative:^(kitty|launcher|logout_dialog)$, no_blur on


-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█

-- INTERNET BROWSER
-- ================

-- Firefox: Picture In Picture Mode
local pip_size = 0.3
hl.window_rule({
  name = "firefox-pip",
  match = {
    class = "^firefox$",
    title = "^Picture-in-Picture$"
  },
  float = true,
  border_color = colors.error,
  size = { "(monitor_w*" .. pip_size .. ")", "(monitor_h*" .. pip_size .. ")" },
  -- NOTE: x=(total_width-(size_x)-border_size) y=(total_height-(size_y)-border_size)
  move = { "(monitor_w-(monitor_w*" .. pip_size .. ")-16)", "(monitor_h-(monitor_h*" .. pip_size .. ")-16)" },
  keep_aspect_ratio = true,
  no_dim = true,
  pin = true,
  no_initial_focus = true,
  idle_inhibit = "always",
  nearest_neighbor = true
})

-- MULTIMEDIA
-- ==========

-- Don't dim media players
hl.window_rule({
  match = { class = "^mpv$" },
  no_dim = true
})
hl.window_rule({
  match = { class = "^feh$" },
  no_dim = true
})

-- Fix: feh Image Viewer losing focus
hl.window_rule({
  match = { class = "^feh$" },
  stay_focused = true
})


-- █▀▄ █▄█ █▄░█ ▄▀█ █▀▄▀█ █ █▀▀   █▀█ █░█ █░░ █▀▀ █▀
-- █▄▀ ░█░ █░▀█ █▀█ █░▀░█ █ █▄▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

-- Colored Window border only on multiple windows (#4d4d4d)
-- windowrule = match:workspace w[t1], border_color rgba(4d4d4d00)
-- count(visible) - count.special => count(tiling + pinned)
-- windowrule = match:workspace w[v1]s[false], border_color rgba(4d4d4d00)
hl.window_rule({
  name = "assistive-border",
  match = {
    workspace = "w[t1]", -- 1 tile only
    -- match = { workspace = "w[v1]s[false]" } -- 1 tile or 1 pin or 1 float
    float = false,
    pin = false
  },
  border_color = "rgba(4d4d4d00)"
})

-- Floating Window border color (#ff6666 #ffd580)
-- windowrule = match:float true, border_color $error

-- Smol Window (Special Workspace)
hl.window_rule({
  name = "smol",
  match = { class = "smol" },
  float = true,
  -- border_color = colors.secondary,
  -- size = (monitor_w*0.602) (monitor_h*0.6)
  size = { "(monitor_w*0.7)", "(monitor_h*0.7)" },
  center = true
})

-- nvim_textinput Window
hl.window_rule({
  name = "textinput",
  match = { class = "textinput" },
  float = true,
  stay_focused = true,
  pin = true,
  size = "(monitor_w*0.7) (monitor_h*0.7)",
  center = true
})


-- █░█░█ █▀█ █▀█ █▄▀ █▀ █▀█ ▄▀█ █▀▀ █▀▀   █▀█ █░█ █░░ █▀▀ █▀
-- ▀▄▀▄▀ █▄█ █▀▄ █░█ ▄█ █▀▀ █▀█ █▄▄ ██▄   █▀▄ █▄█ █▄▄ ██▄ ▄█

-- Create a smol kitty on special workspace
hl.workspace_rule({
  workspace = "special:magic",
  on_created_empty = "kitty --class smol"
})
