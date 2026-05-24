import QtQuick
import Quickshell.Hyprland
import "../config"
import "../components"


Item {
    id: root
    anchors.fill: parent

    SlantedBox {
        slantType: 1
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
}
