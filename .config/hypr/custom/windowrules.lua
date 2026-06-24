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
  no_blur = true,
  pin = true,
  no_initial_focus = true,
  idle_inhibit = "always",
  no_focus = true,
})

-- Cycle through windows with mainMod + n
--[[
Imagine the following scenario:
- workspace 1: kitty terminal
- workspace 2: empty
- workspace 3: firefox window
- Switch to workspace 1 -> Kitty terminal is focused
- Switch to workspace 3 -> Firefox window is focused
- Accidentally switch to workspace 2 -> Pinned firefox-pip is focused
- Switch to workspace 1 -> Pinned firefox-pip is still focused
]]
-- This keybind fixes this issue
-- Keeps firefox-pip no_focus, so it won't get focused but still be able to cycle through it
hl.bind("SUPER + n", function()
  local ws = hl.get_active_workspace()
  local pip_window = nil
  if ws then
    local windows = hl.get_workspace_windows(ws)
    if windows then
      for _, w in ipairs(windows) do
        if w.class == "firefox" and w.title == "Picture-in-Picture" then
          pip_window = w
          break
        end
      end
    end
  end
  if pip_window then
    local active = hl.get_active_window()
    if active and active.address == pip_window.address then
      hl.dispatch(hl.dsp.window.cycle_next())
    else
      hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "false", window = pip_window }))
      hl.dispatch(hl.dsp.focus({ window = pip_window }))
      hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "true", window = pip_window }))
    end
  else
    hl.dispatch(hl.dsp.window.cycle_next())
  end
end)

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
  center = true,
  border_color = "rgba(f9e2afff)" -- Sync to Pixelbar colors
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
  on_created_empty = "kitty --class smol",
})
