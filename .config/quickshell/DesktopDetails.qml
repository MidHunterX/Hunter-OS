import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: root

    // on the desktop wallpaper
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background

    anchors {
        top: true
        left: true
        right: true
    }

    margins.top: 15
    margins.left: 10
    margins.right: 10

    implicitHeight: 35
    color: "transparent"

    // CLOCK
    ParallelogramBox {
        anchors.left: parent.left
        height: parent.height
        width: clockRow.width + (skewOffset * 2) + 20

        color: Colors.surface_container_low
        borderColor: Colors.outline_variant
        opacity: 0.9

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: clock.date.toLocaleTimeString(Qt.locale(), "hh:mm")
                color: Colors.on_surface
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: clock.date.toLocaleDateString(Qt.locale(), "ddd, MMM d")
                color: Colors.on_surface_variant
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // WORKSPACES
    ParallelogramBox {
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        width: workspaceRow.width + (skewOffset * 2) + 20

        color: Colors.surface_container_low
        borderColor: Colors.outline_variant
        opacity: 0.9

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: {
                    var persistent = [1, 2, 3];
                    var result = [];
                    var activeIds = [];

                    for (var j = 0; j < Hyprland.workspaces.values.length; j++) {
                        var ws = Hyprland.workspaces.values[j];
                        if (ws.id > 0) {
                            result.push(ws);
                            activeIds.push(ws.id);
                        }
                    }

                    for (var p = 0; p < persistent.length; p++) {
                        if (activeIds.indexOf(persistent[p]) === -1) {
                            result.push({
                                id: persistent[p],
                                focused: false,
                                urgent: false,
                                toplevels: { values: [] }
                            });
                        }
                    }

                    result.sort(function(a, b) { return a.id - b.id; });
                    return result;
                }

                Item {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter

                    property var workspace: modelData
                    property bool isFocused: workspace.focused
                    property bool isUrgent: workspace.urgent
                    property bool isEmpty: workspace.toplevels.values.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: workspace.id
                        font.pixelSize: 16
                        font.bold: isFocused || !isEmpty
                        color: {
                            if (isUrgent) return "#7CFF00";
                            if (isFocused) return Colors.primary;
                            return isEmpty ? Colors.on_surface_variant : Colors.on_surface;
                        }
                    }

                    // Focus underline indicator
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -6
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isFocused ? 14 : (isEmpty ? 0 : 4)
                        height: 2
                        color: isFocused ? Colors.primary : Colors.on_surface_variant

                        Behavior on width { NumberAnimation { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -5
                        onClicked: Hyprland.dispatch("workspace " + workspace.id)
                    }
                }
            }
        }
    }

    // BATTERY
    ParallelogramBox {
        id: batteryBox
        anchors.right: parent.right
        height: parent.height
        width: batteryRow.width + (skewOffset * 2) + 20

        color: Colors.surface_container_low
        borderColor: Colors.outline_variant
        opacity: 0.9

        property int batteryPercent: 0

        Process {
            id: batteryProc
            command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    var percent = parseInt(this.text.trim())
                    if (!isNaN(percent)) {
                        batteryBox.batteryPercent = Math.max(0, Math.min(100, percent))
                    }
                }
            }
        }

        Timer {
            interval: 10000
            running: true
            repeat: true
            onTriggered: batteryProc.running = true
        }

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "PWR"
                color: Colors.primary
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: batteryBox.batteryPercent + "%"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                color: {
                    if (batteryBox.batteryPercent > 50) return Colors.on_surface;
                    else if (batteryBox.batteryPercent > 20) return "#f9e2af"; // Warning
                    else return "#f38ba8"; // Critical
                }
            }
        }
    }
}
