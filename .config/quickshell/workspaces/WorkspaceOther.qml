import QtQuick
import Quickshell.Hyprland
import "../components"

Row {
    id: root
    spacing: 10
    height: 8 // To accomodate numbers

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

    // SECTION 2: Non-persistent workspaces (dynamic)
    // Shows workspaces that exist but aren't in persistentWorkspaces,
    // but hides them if they're unfocused AND empty
    Repeater {
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
            height: root.height
            workspace: modelData
            showText: true
        }
    }
}
