import QtQuick
import Quickshell.Hyprland
import "../components"

Row {
    id: root
    spacing: 10
    height: 8 // To accomodate numbers

    property int primaryLength: 70
    property int secondaryLength: 30

    Repeater {
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
            height: root.height
            workspace: modelData
        }
    }
}
