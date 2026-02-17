import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  width: 300

  property var thicc: 3
  property var gap: 5
  property color c_background: Colors.outline
  property color c_high: Colors.primary // "#a6e3a1"
  property color c_low: "#f9e2af"
  property color c_crit: "#f38ba8"

  property int batteryPercent: 0

  // Read battery percentage
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

  // Update battery every 5 seconds
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: batteryProc.running = true
  }

  Row {
    anchors.fill: parent
    spacing: gap

    // Create 10 segments (each representing 10%)
    Repeater {
      model: 10

      Rectangle {
        width: (parent.width - 9 * parent.spacing) / 10
        height: thicc
        color: c_background

        Rectangle {
          anchors.fill: parent
          visible: root.batteryPercent >= (index + 1) * 10
          color: {
            // Color based on battery level
            if (root.batteryPercent > 50) return c_high
            else if (root.batteryPercent > 20) return c_low
            else return c_crit
          }
        }
      }
    }
  }
}
