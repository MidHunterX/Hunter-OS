import QtQuick
import "../config"
import "../components"

Item {
    id: root
    implicitWidth: 13
    implicitHeight: 150

    WifiMonitor {
        id: wifi
    }

    readonly property color strengthColor: {
        if (!wifi.isOnline) return "#FF6969"
        if (wifi.signalStrength > 85) return "#FFDD69" // Golden Connection!
        return Colors.primary // Default Color
    }

    SlantedBox {
        anchors.fill: parent
        vertical: true
        slantType: "right"
        skewOffset: 10
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant
        borderWidth: 0

        // Strength Meter Track
        Rectangle {
            width: 4
            height: parent.height
            color: Colors.outline

            // Strength Fill (Vertical)
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * (wifi.signalStrength / 100)
                color: root.strengthColor

                Behavior on height {
                    NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
