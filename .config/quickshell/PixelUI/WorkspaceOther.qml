import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"
import "../logic/WorkspaceLogic.js" as Logic

Item {
    id: root
    height: 13
    width: contentRow.width + 30
    visible: otherRepeater.count > 0

    property list<int> persistentWorkspaces: [1, 2, 3]
    property int primaryLength: 70
    property int secondaryLength: 30

    SlantedBox {
        anchors.fill: parent
        slantType: "right"
        skewOffset: (parent.height / 2)
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
                model: Logic.getOther(Hyprland.workspaces.values, root.persistentWorkspaces)

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
