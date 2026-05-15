-- █▄▀ █▀▀ █▄█   █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
-- █░█ ██▄ ░█░   █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
-- Keys (use the name after XKB_KEY_):
-- https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h

-- VARIABLES
-- ---------
local mainMod = "SUPER"
local terminal = "kitty"
local browser = "python ~/Mid_Hunter/scripts/assistants/hyprchan/run_firefox.py"

local function launcher()
    local menu = "vicinae open" -- wofi -> fuzzel -> vicinae
    hl.on("hyprland.start", function()
        hl.exec_cmd("vicinae server")
    end)
    hl.bind("ALT + SPACE", hl.dsp.exec_cmd(menu))
end
launcher()

NOTIFY_SEND = "notify-send -r 69"
NOTIFY_CLOSE = "dunstctl close 69"


-- █▀▄▀█ █ █▀ █▀▀
-- █░▀░█ █ ▄█ █▄▄
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
-- Simple Screenshot Functions
hl.bind("Print", hl.dsp.exec_cmd("grim | wl-copy"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("grim ~/Pictures/$(date +%Y%m%d-%H%M%S-%2N).jpg | wl-copy"))
-- Logout Screen
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("wlogout --protocol layer-shell"))
-- Exit Hyprland
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("bash ~/Mid_Hunter/scripts/kill_hypr.sh"))
-- hl.bind(MOD .. " + SHIFT + B", hl.dsp.exit())


-- █░█ █▀█ █ █▀▀ █▀▀   ▀█▀ █▄█ █▀█ █ █▄░█ █▀▀   █▀▄▀█ █▀█ █▀▄ █▀▀
-- ▀▄▀ █▄█ █ █▄▄ ██▄   ░█░ ░█░ █▀▀ █ █░▀█ █▄█   █░▀░█ █▄█ █▄▀ ██▄
-- Voice Typing mode [SCROLL_LOCK] to toggle
local whisper = "perl ~/.config/hypr/scripts/whisper.pl"

---@param status "start"|"stop"
function VoiceType(status)
    if status == "start" then
        hl.dispatch(hl.dsp.exec_cmd(whisper .. " start"))
        hl.dispatch(hl.dsp.submap("Whisper"))
    elseif status == "stop" then
        hl.dispatch(hl.dsp.exec_cmd(whisper .. " stop"))
        hl.dispatch(hl.dsp.submap("reset"))
    end
end

hl.bind(mainMod .. " + W", function() VoiceType("start") end, { release = true })
hl.define_submap("Whisper", function()
    hl.bind("W", function() VoiceType("stop") end, { release = true })
end)


-- ▀█▀ █▀█ ▄▀█ █▄░█ █▀ █▀▀ █▀█ █▀█ █▀▄▀█   █▀▄▀█ █▀█ █▀▄ █▀▀
-- ░█░ █▀▄ █▀█ █░▀█ ▄█ █▀░ █▄█ █▀▄ █░▀░█   █░▀░█ █▄█ █▄▀ ██▄
-- Transformation mode [MOD+T] like Photoshop
hl.bind("SUPER + T", hl.dsp.submap("Transform"))
hl.define_submap("Transform", function()
    hl.bind("H", hl.dsp.focus({ direction = "l" }), { repeating = true })
    hl.bind("J", hl.dsp.focus({ direction = "d" }), { repeating = true })
    hl.bind("K", hl.dsp.focus({ direction = "u" }), { repeating = true })
    hl.bind("L", hl.dsp.focus({ direction = "r" }), { repeating = true })
    hl.bind("SHIFT + H", hl.dsp.window.move({ direction = "l" }))
    hl.bind("SHIFT + J", hl.dsp.window.move({ direction = "d" }))
    hl.bind("SHIFT + K", hl.dsp.window.move({ direction = "u" }))
    hl.bind("SHIFT + L", hl.dsp.window.move({ direction = "r" }))
    -- Resize: Quick Major Adjustments
    hl.bind("CTRL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
    hl.bind("CTRL + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
    hl.bind("CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
    hl.bind("CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
    -- Resize: Precise Minor Adjustments
    hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
    hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    -- Exit
    hl.bind("escape", hl.dsp.submap("reset"))
    local TransformMenu =
    [[ ' "Transform Mode" "--" " hjkl - Select Window\n SHIFT + hjkl - Move Window\n CTRL + hjkl - Resize Window\n escape - exit"' ]]
    hl.bind("SHIFT + slash", hl.dsp.exec_cmd(NOTIFY_SEND .. TransformMenu))
end)


-- █▀▀ █░█ █▀█ █▀ █▀█ █▀█   █▀▄▀█ █▀█ █▀▄ █▀▀
-- █▄▄ █▄█ █▀▄ ▄█ █▄█ █▀▄   █░▀░█ █▄█ █▄▀ ██▄
-- We replace shell commands with native Lua functions using `hl.config` and `hl.dispatch`.

---@param visibility "show"|"hide"|"yeet"
local function cursor(visibility)
    if visibility == "show" then
        hl.config({ cursor = { inactive_timeout = 0, hide_on_key_press = false } })
    elseif visibility == "hide" then
        hl.config({ cursor = { inactive_timeout = 3, hide_on_key_press = true } })
    elseif visibility == "yeet" then
        hl.dispatch(hl.dsp.cursor.move({ x = 1920, y = 540 }))
    end
end

hl.define_submap("Cursor", function()
    -- Source: https://github.com/moverest/wl-kbptr
    -- Find position and Jump Cursor to it (requires wl-kbptr)
    hl.bind("f", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.dispatch(hl.dsp.exec_cmd(
            "wl-kbptr -o modes=tile && wlrctl pointer move 0 1 && hyprctl dispatch 'hl.dispatch(hl.dsp.submap(\"Cursor\"))'"))
    end)

    -- SUBMAP: ColorPicker
    hl.define_submap("ColorPicker", function()
        hl.bind("j", hl.dsp.exec_cmd("wlrctl pointer move 0 1"), { repeating = true })
        hl.bind("k", hl.dsp.exec_cmd("wlrctl pointer move 0 -1"), { repeating = true })
        hl.bind("l", hl.dsp.exec_cmd("wlrctl pointer move 1 0"), { repeating = true })
        hl.bind("h", hl.dsp.exec_cmd("wlrctl pointer move -1 0"), { repeating = true })
        hl.bind("SHIFT + J", hl.dsp.exec_cmd("wlrctl pointer move 0 5"), { repeating = true })
        hl.bind("SHIFT + K", hl.dsp.exec_cmd("wlrctl pointer move 0 -5"), { repeating = true })
        hl.bind("SHIFT + L", hl.dsp.exec_cmd("wlrctl pointer move 5 0"), { repeating = true })
        hl.bind("SHIFT + H", hl.dsp.exec_cmd("wlrctl pointer move -5 0"), { repeating = true })
        -- Pick Color -> Keep mouse away -> Return full control to user
        hl.bind("i", function()
            hl.dispatch(hl.dsp.exec_cmd("wlrctl pointer click left"))
            cursor("yeet")
            cursor("hide")
            hl.dispatch(hl.dsp.submap("reset"))
        end)
        -- exit ColorPicker mode
        hl.bind("escape", function()
            hl.dispatch(hl.dsp.exec_cmd("pkill hyprpicker"))
            hl.dispatch(hl.dsp.submap("Cursor"))
        end)
    end)
    hl.bind("C", function()
        hl.dispatch(hl.dsp.submap("ColorPicker"))
        hl.dispatch(hl.dsp.exec_cmd("hyprpicker | wl-copy"))
    end)

    -- Cursor movement (requires wlrctl)
    hl.bind("j", hl.dsp.exec_cmd("wlrctl pointer move 0 10"), { repeating = true })
    hl.bind("k", hl.dsp.exec_cmd("wlrctl pointer move 0 -10"), { repeating = true })
    hl.bind("l", hl.dsp.exec_cmd("wlrctl pointer move 10 0"), { repeating = true })
    hl.bind("h", hl.dsp.exec_cmd("wlrctl pointer move -10 0"), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.exec_cmd("wlrctl pointer move 0 50"), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.exec_cmd("wlrctl pointer move 0 -50"), { repeating = true })
    hl.bind("SHIFT + L", hl.dsp.exec_cmd("wlrctl pointer move 50 0"), { repeating = true })
    hl.bind("SHIFT + H", hl.dsp.exec_cmd("wlrctl pointer move -50 0"), { repeating = true })

    -- Click Emulation
    hl.bind("i", hl.dsp.exec_cmd("wlrctl pointer click left"))
    hl.bind("o", hl.dsp.exec_cmd("wlrctl pointer click right"))
    hl.bind("m", hl.dsp.exec_cmd("wlrctl pointer click middle"))

    -- Scroll Emulation (up/down)
    hl.bind("u", hl.dsp.exec_cmd("wlrctl pointer scroll 10 0"), { repeating = true })
    hl.bind("d", hl.dsp.exec_cmd("wlrctl pointer scroll -10 0"), { repeating = true })

    -- Scroll Emulation (left/right)
    hl.bind("b", hl.dsp.exec_cmd("wlrctl pointer scroll 0 -10"), { repeating = true })
    hl.bind("w", hl.dsp.exec_cmd("wlrctl pointer scroll 0 10"), { repeating = true })

    -- Exit and yeet
    local close_keys = { "x", "q" }
    for _, key in pairs(close_keys) do
        hl.bind(key, function()
            hl.dispatch(hl.dsp.submap("reset"))
            cursor("yeet")
            cursor("hide")
        end)
    end

    -- Exit temporarily
    hl.bind("escape", function()
        hl.dispatch(hl.dsp.submap("reset"))
        cursor("hide")
    end)
end)
hl.bind("SUPER + C", function()
    hl.dispatch(hl.dsp.submap("Cursor"))
    cursor("show")
end)


-- █▀▀ ▀▄▀ █▀▀ █▀▀ █░█ ▀█▀ █▀▀   █▀▄▀█ █▀█ █▀▄ █▀▀
-- ██▄ █░█ ██▄ █▄▄ █▄█ ░█░ ██▄   █░▀░█ █▄█ █▄▀ ██▄

hl.bind(mainMod .. " + E", hl.dsp.submap("Execute"))
hl.define_submap("Execute", function()
    -- SUBMAP: Brightness
    local BrightnessMenu =
    [[ "Brightness Mode (e > b)" "--" " u - brightness +2\n d - brightness -1\n x - learn\n l - lock toggle\n q - exit\n esc - exit" ]]
    hl.define_submap("Brightness", function()
        hl.bind("u", hl.dsp.exec_cmd("swayosd-client --brightness +2"), { repeating = true })
        hl.bind("d", hl.dsp.exec_cmd("swayosd-client --brightness -1"), { repeating = true })
        local exit_brightness = function()
            hl.dispatch(hl.dsp.submap("reset"))
            hl.exec_cmd(NOTIFY_CLOSE)
        end
        -- lock/unlock
        hl.bind("l", function()
            hl.exec_cmd("perl ~/automata/radiance/worker.pl --toggle")
            exit_brightness()
        end)
        -- learn and exit
        hl.bind("x", function()
            hl.exec_cmd("perl ~/automata/radiance/learn.pl")
            exit_brightness()
        end)
        -- exit
        hl.bind("q", exit_brightness)
        hl.bind("escape", exit_brightness)
        -- help
        hl.bind("SHIFT + slash", hl.dsp.exec_cmd(NOTIFY_SEND .. BrightnessMenu))
    end)
    hl.bind("B", function()
        hl.dispatch(hl.dsp.submap("Brightness"))
        hl.exec_cmd(NOTIFY_SEND .. BrightnessMenu)
    end)

    -- Firefox Experiment Profile [MOD+E E]
    hl.bind("E", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd(browser .. " Experiment")
    end)
    -- Firefox Personal Profile [MOD+E F]
    hl.bind("F", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd(browser .. " Personal")
    end)
    -- Kitty Terminal [MOD+F K]
    hl.bind("K", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd(terminal .. " ~/Mid_Hunter/scripts/fetch.pl")
    end)
    -- nvim textinput
    hl.bind("N", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd("perl ~/Mid_Hunter/scripts/nvim_textinput.pl")
    end)
    -- OCR using Tesseract
    hl.bind("P", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd("grim -g \"$(slurp)\" - | tesseract - - | wl-copy")
    end)

    -- SUBMAP: Volume
    local VolumeMenu =
    [[ "Volume Mode (e > v)" "--" " u - volume +1\n d - volume -1\n m - mute\n x - exit\n q - exit\n escape - exit" ]]
    hl.define_submap("Volume", function()
        hl.bind("u", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { repeating = true })
        hl.bind("d", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { repeating = true })
        hl.bind("m", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
        local exit_volume = function()
            hl.dispatch(hl.dsp.submap("reset"))
            hl.exec_cmd(NOTIFY_CLOSE)
        end
        -- exit submap
        hl.bind("x", exit_volume)
        hl.bind("q", exit_volume)
        hl.bind("escape", exit_volume)
        -- help
        hl.bind("SHIFT + slash", hl.dsp.exec_cmd(NOTIFY_SEND .. VolumeMenu))
    end)
    hl.bind("V", function()
        hl.dispatch(hl.dsp.submap("Volume"))
        hl.exec_cmd(NOTIFY_SEND .. VolumeMenu)
    end)

    -- Toggle Waybar
    hl.bind("SHIFT + W", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd("killall -SIGUSR1 waybar")
    end)
    hl.bind("W", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.exec_cmd("pkill -x waybar 2>/dev/null; waybar")
    end)

    -- exit submap
    hl.bind("escape", hl.dsp.submap("reset"))
    -- hl.bind("escape", function() hl.dispatch(hl.dsp.submap("reset")); hl.exec_cmd("dunstctl close 69") end)
    local ExecuteMenu =
    [[ "Execute Mode (e)" "--" " b - [Brightness Mode]\n e - Entertainment\n f - Firefox Browser\n k - Kitty Terminal\n n - Nvim Input\n p - Printscreen\n P - Printscreen OCR \n v - [Volume Mode]\n w - Refresh Waybar\n escape - Exit" ]]
    -- help
    hl.bind("SHIFT + slash", hl.dsp.exec_cmd(NOTIFY_SEND .. ExecuteMenu))
end)


-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀▄▀█ ▄▀█ █▄░█ ▄▀█ █▀▀ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █░▀░█ █▀█ █░▀█ █▀█ █▄█ ██▄ █░▀░█ ██▄ █░▀█ ░█░

hl.bind("SUPER + X", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
-- TODO: hl.bind("SUPER + M", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + V", hl.dsp.window.float())
-- Example special workspace (scratchpad)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

local vim_keys = { h = "left", l = "right", k = "up", j = "down" }
for key, dir in pairs(vim_keys) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

local finger_workspace = { U = "1", I = "2", O = "3" }
for key, workspace in pairs(finger_workspace) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

-- Cycle through windows with mainMod + n
hl.bind(mainMod .. " + n", hl.dsp.window.cycle_next())


-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█ █▀   █▀ ▀█▀ █▄█ █░░ █▀▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀ ▄█   ▄█ ░█░ ░█░ █▄▄ ██▄
-- [Super+.] Emoji Selector
hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("bash ~/Mid_Hunter/scripts/menu_emoji.sh"))

-- [Alt+Tab] through existing workspaces
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))


-- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█   █▀█ █▀█ █░█░█
-- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█   █▀▄ █▄█ ▀▄▀▄▀
-- Volume Keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true })
-- Brightness Keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brillo -q -A 1"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brillo -q -U 1"), { locked = true })
