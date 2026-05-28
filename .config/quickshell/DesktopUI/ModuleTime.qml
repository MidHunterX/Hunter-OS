import QtQuick
import Quickshell
import "../config"
import "../components"

Item {
    id: root
    anchors.fill: parent

    SlantedBox {
        slantType: "right"
        anchors.left: parent.left
        height: parent.height
        width: clockRow.width + (skewOffset * 2) + 20
        skewOffset: (parent.height / 2)

        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 12

            Text {
                text: clock.date.toLocaleTimeString(Qt.locale(), "hh:mm")
                color: Colors.on_surface
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: clock.date.toLocaleDateString(Qt.locale(), "ddd, MMM d")
                color: Colors.on_surface_variant
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
