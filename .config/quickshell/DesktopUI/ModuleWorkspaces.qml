import QtQuick
import Quickshell.Hyprland
import "../config"
import "../components"

Item {
    id: root
    implicitWidth: mainContainer.width
    implicitHeight: 35
    anchors.horizontalCenter: parent.horizontalCenter

    // Map IDs to labels as seen in your screenshot
    readonly property var workspaceNames: ({
        1: "dev",
        2: "www",
        3: "exp",
        "-99": "scratch" // Example for a special workspace
    })

    // The logic to aggregate workspaces exactly like PixelUI
    property var workspaceList: {
        var persistent = [1, 2, 3];
        var result = [];
        var seenIds = new Set();

        // 1. Get Special and 'Other' (Dynamic) workspaces
        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            var ws = Hyprland.workspaces.values[i];

            // Special workspaces (id < 0)
            if (ws.id < 0) {
                result.push(ws);
                seenIds.add(ws.id);
                continue;
            }

            // 'Other' workspaces (id > 0, not persistent, and must be focused or non-empty)
            if (persistent.indexOf(ws.id) === -1) {
                if (ws.focused || ws.toplevels.values.length > 0) {
                    result.push(ws);
                    seenIds.add(ws.id);
                }
            }
        }

        // 2. Add Persistent workspaces if they aren't already in the list
        for (var p = 0; p < persistent.length; p++) {
            var id = persistent[p];
            if (!seenIds.has(id)) {
                // Find existing object or create placeholder
                var existing = null;
                for (var k = 0; k < Hyprland.workspaces.values.length; k++) {
                    if (Hyprland.workspaces.values[k].id === id) {
                        existing = Hyprland.workspaces.values[k];
                        break;
                    }
                }

                result.push(existing || {
                    id: id,
                    focused: false,
                    urgent: false,
                    toplevels: { values: [] }
                });
            }
        }

        // Sort: Special first (negative IDs), then by numeric ID
        result.sort(function(a, b) { return a.id - b.id; });
        return result;
    }

    // Main pill-shaped background
    Rectangle {
        id: mainContainer
        anchors.centerIn: parent
        height: 38
        width: workspaceRow.width + 12
        radius: height / 2
        color: "#1e1a1b" // Dark background from screenshot
        border.color: "#2d2829"
        border.width: 1

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: root.workspaceList

                Item {
                    id: workspaceButton
                    width: Math.max(60, label.implicitWidth + 40)
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter

                    property var ws: modelData
                    property bool isFocused: ws.focused
                    property bool isEmpty: ws.toplevels ? ws.toplevels.values.length === 0 : true
                    property bool isUrgent: ws.urgent

                    // Individual Button Pill
                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2

                        // Colors based on screenshot
                        color: {
                            if (isUrgent) return "#7CFF00";
                            if (isFocused) return "#ffffff"; // Light salmon/coral
                            return "#4d342e"; // Muted dark brown
                        }

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Text {
                        id: label
                        anchors.centerIn: parent
                        // Use name mapping if exists, otherwise fallback to ID
                        text: root.workspaceNames[ws.id] || ws.id
                        font.pixelSize: 13
                        font.bold: true
                        color: isFocused ? "#3e2723" : "#efdfdb" // Dark text on light, light text on dark
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + ws.id)
                    }
                }
            }
        }
    }
}
