import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"

Item {
    id: root
    height: 13
    width: contentRow.width + 25
    visible: specialRepeater.count > 0

    property int primaryLength: 70
    property int secondaryLength: 30

    SlantedBox {
        anchors.fill: parent
        slantType: "left"
        skewOffset: (parent.height / 2)
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        Row {
            id: contentRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            height: 8 // To accomodate numbers

            Repeater {
                id: specialRepeater
                model: {
                    var result = [];
                    for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                        var ws = Hyprland.workspaces.values[i];
                        if (ws.id < 0) result.push(ws);
                    }
                    // Sort by ID to maintain order
                    result.sort(function(a, b) { return a.id - b.id; });
                    return result;
                }

                WorkspaceItem {
                    width: root.secondaryLength
                    height: parent.height
                    workspace: modelData
                }
            }
        }
    }
}
