import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"
import "../logic/WorkspaceLogic.js" as Logic

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
                model: Logic.getSpecial(Hyprland.workspaces.values)

                WorkspaceItem {
                    width: root.secondaryLength
                    height: parent.height
                    workspace: modelData
                }
            }
        }
    }
}
