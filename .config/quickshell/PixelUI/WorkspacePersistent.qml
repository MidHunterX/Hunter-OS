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

    // SECTION 1: Persistent Workspaces (always shown)
    Repeater {
        model: root.persistentWorkspaces

        WorkspaceItem {
            width: root.primaryLength
            height: root.height

            // CHECK: workspace object for this ID
            workspace: {
                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                    if (Hyprland.workspaces.values[i].id === modelData) {
                        return Hyprland.workspaces.values[i];
                    }
                }
                return null;
            }
            workspaceId: modelData
        }
    }
}
