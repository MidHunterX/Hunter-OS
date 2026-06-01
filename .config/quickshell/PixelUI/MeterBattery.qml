import QtQuick
import Quickshell
import "../config"
import "../components"

Item {
    id: root
    width: 300
    implicitHeight: 13

    property var thicc: 3
    property var gap: 5
    property color c_background: Colors.outline
    property color c_high: Colors.primary
    property color c_low: "#f9e2af"
    property color c_crit: "#f38ba8"

    property int batteryPercent: monitor.batteryPercent
    property bool isCharging: monitor.isCharging

    BatteryMonitor { id: monitor }

    // Tracks which filled segment index currently holds the peak of the opacity wave
    property int sweepIndex: 0

    Timer {
        id: sweepTimer
        interval: 200
        running: root.isCharging
        repeat: true
        onTriggered: {
            // Calculate how many segments are currently filled
            let filledCount = 0;
            for (let i = 0; i < 10; i++) {
                if (root.batteryPercent >= ((i + 1) * 10) - 5) {
                    filledCount++;
                }
            }

            if (filledCount > 0) {
                root.sweepIndex = (root.sweepIndex + 1) % filledCount;
            } else {
                root.sweepIndex = 0;
            }
        }
        onRunningChanged: {
            if (!running) {
                root.sweepIndex = 0;
            }
        }
    }

    SlantedBox {
        anchors.fill: parent
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant
        borderWidth: 1
        slantType: "left"
        skewOffset: (parent.height / 2)

        Row {
            width: parent.width
            spacing: root.gap

            Repeater {
                model: 10
                Rectangle {
                    width: (parent.width - 9 * parent.spacing) / 10
                    height: root.thicc
                    color: root.c_background

                    Rectangle {
                        id: fillBar
                        anchors.fill: parent

                        opacity: {
                            let isFilled = root.batteryPercent >= ((index + 1) * 10) - 5;
                            if (!isFilled) return 0.0;

                            if (root.isCharging) {
                                let distance = Math.abs(index - root.sweepIndex);
                                if (distance === 0) return 0.00; // Wave Peak
                                else if (distance === 1) return 0.50; // Wave Slope
                                else return 1.0; // Valley
                            } else {
                                return 1.0; // Static solid filled state
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 400 }
                        }

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
}
