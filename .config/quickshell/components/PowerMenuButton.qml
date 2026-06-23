import QtQuick
import "../config"

Item {
    id: root

    property string text: "Text"
    property string icon: "icon"
    property string slantType: "right"

    property string keyBind: ""

    signal clicked()

    implicitWidth: 300
    implicitHeight: 150

    SlantedBox {
        anchors.fill: parent
        slantType: root.slantType
        skewOffset: (parent.height / 2)

        color: mouseArea.containsMouse ? Colors.surface_container_highest : Colors.primary
        borderColor: mouseArea.containsMouse ? Colors.outline_variant : Colors.primary
        borderWidth: 2

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on borderColor { ColorAnimation { duration: 150 } }

        Column {
            anchors.centerIn: parent

            Text {
                text: root.icon
                font.pixelSize: 80
                anchors.horizontalCenter: parent.horizontalCenter
                color: mouseArea.containsMouse ? Colors.on_surface : Colors.on_primary
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            Text {
                text: root.keyBind === "" ? root.text : root.text + " [" + root.keyBind + "]"
                font.pixelSize: 16
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                color: mouseArea.containsMouse ? Colors.on_surface_variant : Colors.on_primary
                Behavior on color { ColorAnimation { duration: 350 } }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
