import QtQuick
import Quickshell
import Quickshell.Hyprland
import "config"
import "components"

Item {
    id: root
    // Since this is wrapped around ParallelogramBox, this acts as the padding
    implicitHeight: 30
    implicitWidth: Math.max(240, submapContent.width + 40)

    property color c_foreground: Colors.on_primary
    property color c_background: Colors.primary
    property color c_border: Colors.primary

    property string activeSubmap: ""
    readonly property bool isActive: activeSubmap !== ""

    // Hyprland socket2 IPC event
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap") {
                root.activeSubmap = event.data;
            }
        }
    }

    opacity: isActive ? 1.0 : 0.0
    visible: opacity > 0

    SlantedBox {
        anchors.fill: parent
        slantType: "top"
        skewOffset: (parent.height / 3)

        color: c_background
        borderColor: c_border
        borderWidth: 2

        Row {
            id: submapContent
            anchors.centerIn: parent
            spacing: 12

            // Blinking recording-style dot
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: c_foreground
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: root.isActive
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                }
            }

            Text {
                text: root.activeSubmap.toUpperCase() + " MODE"
                color: c_foreground
                font.pixelSize: 16
                font.bold: true
                font.letterSpacing: 1
            }
        }
    }
}
