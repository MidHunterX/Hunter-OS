import QtQuick
import Quickshell.Io

Item {
    id: root
    property int batteryPercent: 0
    property int interval: 10000

    Process {
        id: batteryProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var percent = parseInt(this.text.trim())
                if (!isNaN(percent)) {
                    root.batteryPercent = Math.max(0, Math.min(100, percent))
                }
            }
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }
}
