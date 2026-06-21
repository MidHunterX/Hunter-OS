import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"

Item {
    id: root
    height: 13
    width: contentRow.width + 30 // Extra width for slant padding

    property list<int> persistentWorkspaces: [1, 2, 3]
    property int primaryLength: 70
    property int secondaryLength: 30

    SlantedBox {
        anchors.fill: parent
        slantType: "top"
        skewOffset: (parent.height / 2)
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        Row {
            id: contentRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            height: 8 // To accomodate numbers

            // SECTION 1: Persistent Workspaces (always shown)
            Repeater {
                model: root.persistentWorkspaces

                WorkspaceItem {
                    width: root.primaryLength
                    height: parent.height

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
    }
}
