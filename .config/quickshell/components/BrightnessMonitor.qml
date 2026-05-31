// Dependencies: brightnessctl, libinotify

import QtQuick
import Quickshell.Io

Item {
    id: root
    property int brightness: 0

    Process {
        id: brightnessProc
        // ALGORITHM:
        // 1. Emit current brightness.
        // 2. Block/wait until the backlight file is modified using inotifywait.
        // 3. If inotifywait fails (e.g. missing package), fallback to sleep to prevent CPU thrashing.
        // 4. Repeat forever.
        command: [
            "sh",
            "-c",
            "while true; do brightnessctl -m | cut -d, -f4 | tr -d '%'; inotifywait -qq -e modify /sys/class/backlight/*/brightness || sleep 2; done"
        ]
        running: true

        // SplitParser streams stdout continuously, reacting to each new line individually
        stdout: SplitParser {
            onRead: data => {
                var value = parseInt(data.trim())
                root.brightness = isNaN(value) ? 0 : value
            }
        }
    }
}
