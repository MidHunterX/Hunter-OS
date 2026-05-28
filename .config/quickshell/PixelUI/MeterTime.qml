import QtQuick
import Quickshell
import "../config"
import "../components"

Item {
    id: root
    width: 300
    implicitHeight: 13

    property var thicc: 3
    property var gap: 10
    property color c_background: Colors.outline
    property color c_foreground: "#FFFFFF"

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    property int currentMinute: clock.date.getMinutes()

    SlantedBox {
        anchors.fill: parent
        slantType: "right"
        skewOffset: (parent.height / 2)
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        Row {
            // anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            spacing: root.gap

            // First half
            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: root.thicc
                color: root.c_background
                Rectangle {
                    width: root.currentMinute <= 30 ? parent.width * (root.currentMinute / 30.0) : parent.width
                    height: parent.height
                    color: root.c_foreground
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            // Second half
            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: root.thicc
                color: root.c_background
                Rectangle {
                    width: root.currentMinute > 30 ? parent.width * ((root.currentMinute - 30) / 30.0) : 0
                    height: parent.height
                    color: root.c_foreground
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }
    }
}
