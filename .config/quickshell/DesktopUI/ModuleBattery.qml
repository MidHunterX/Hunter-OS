import QtQuick
import "../config"
import "../components"


Item {
    id: root
    anchors.fill: parent

    SlantedBox {
        id: batteryBox
        slantType: "left"
        anchors.right: parent.right
        height: parent.height
        width: batteryRow.width + (skewOffset * 2) + 20
        skewOffset: (parent.height / 2)

        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant

        property int batteryPercent: monitor.batteryPercent

        BatteryMonitor {
            id: monitor
        }

        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "PWR"
                color: Colors.primary
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: batteryBox.batteryPercent + "%"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                color: {
                    if (batteryBox.batteryPercent > 50) return Colors.on_surface;
                    else if (batteryBox.batteryPercent > 20) return "#f9e2af"; // Warning
                    else return "#f38ba8"; // Critical
                }
            }
        }
    }
}
