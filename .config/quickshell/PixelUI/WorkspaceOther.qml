import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"

Item {
    id: root
    height: 13
    width: contentRow.width + 30
    visible: otherRepeater.count > 0

    property list<int> persistentWorkspaces: [1, 2, 3]
    property int primaryLength: 70
    property int secondaryLength: 30

    // Helper function to check if workspace ID is in persistent list
    function isPersistent(id) {
        for (var i = 0; i < persistentWorkspaces.length; i++) {
            if (persistentWorkspaces[i] === id) return true;
        }
        return false;
    }

    SlantedBox {
        anchors.fill: parent
        slantType: "right"
        skewOffset: (parent.height / 3)
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 10
            height: 12 // To accomodate numbers

            // SECTION 2: Non-persistent workspaces (dynamic)
            // Shows workspaces that exist but aren't in persistentWorkspaces,
            // but hides them if they're unfocused AND empty
            Repeater {
                id: otherRepeater
                model: {
                    var result = [];
                    for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                        var ws = Hyprland.workspaces.values[i];
                        if (root.isPersistent(ws.id)) continue;
                        if (!ws.focused && ws.toplevels.values.length === 0) continue;
                        if (ws.id < 0) continue; // Exclude Special Workspaces
                        result.push(ws);
                    }
                    // Sort by ID to maintain order
                    result.sort(function(a, b) { return a.id - b.id; });
                    return result;
                }

                WorkspaceItem {
                    width: root.secondaryLength
                    height: parent.height
                    workspace: modelData
                    showText: true
                }
            }
        }
    }
}
