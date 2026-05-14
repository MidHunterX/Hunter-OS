-- █▀▀ ▀▄▀ █▀▀ █▀▀
-- ██▄ █░█ ██▄ █▄▄
-- Execute your favorite apps at launch

hl.on("hyprland.start", function()
    -- ESSENTIALS
    hl.exec_cmd("iio-hyprland") -- Accelerometer based Auto Screen Orientation
    hl.exec_cmd("waybar") -- Status Bar
    hl.exec_cmd("quickshell") -- GUI Shell Layer
    hl.exec_cmd("swayosd-server") -- OSD Window
    hl.exec_cmd("awww-daemon") -- Wayland Wallpaper Daemon
    hl.exec_cmd("expression") -- Custom Wallpaper Engine

    -- AUTOMATAS
    hl.exec_cmd("perl ~/automata/radiance/worker.pl")
    hl.exec_cmd("perl ~/automata/stasis/worker.pl")

    -- NOTIFICATIONS
    -- hl.exec_cmd("python ~/Mid_Hunter/scripts/assistants/archchan/notify_battery.py") -- Replaced by Quickshell pixelbar
    hl.exec_cmd("python ~/Mid_Hunter/scripts/assistants/archchan/notify_heat.py")

    -- move cursor aside
    hl.exec_cmd("sleep 0.1 && hyprctl dispatch movecursor 1920 540")
end)
