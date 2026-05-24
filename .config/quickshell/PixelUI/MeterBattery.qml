import QtQuick
import Quickshell
import "../config"
import "../components"

Item {
    id: root
    width: 300

    property var thicc: 3
    property var gap: 5
    property color c_background: Colors.outline
    property color c_high: Colors.primary
    property color c_low: "#f9e2af"
    property color c_crit: "#f38ba8"

    property int batteryPercent: monitor.batteryPercent

    BatteryMonitor {
        id: monitor
    }

    Row {
        anchors.fill: parent
        spacing: gap

        Repeater {
            model: 10  // 10 segments with each representing 10%

            Rectangle {
                width: (parent.width - 9 * parent.spacing) / 10
                height: thicc
                color: root.c_background

                Rectangle {
                    anchors.fill: parent
                    visible: root.batteryPercent >= ((index + 1) * 10) - 5
                    color: {
                        if (root.batteryPercent > 40) return root.c_high
                        else if (root.batteryPercent > 20) return root.c_low
                        else return root.c_crit
                    }
                }
            }
        }
    }
}
