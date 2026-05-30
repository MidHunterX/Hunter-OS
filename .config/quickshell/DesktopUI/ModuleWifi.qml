import QtQuick
import "../config"
import "../components"

Item {
    id: root

    // Number of segments for the meter
    property int segments: 5
    property int segment_size: 8

    WifiMonitor {
        id: wifi
    }

    readonly property color activeColor: {
        if (!wifi.isOnline) return "#FF6969" // Disconnected/No Internet
        if (wifi.signalStrength > 85) return "#FFDD69" // Excellent
        return Colors.primary
    }

    SlantedBox {
        id: outerBox
        anchors.fill: parent

        // Outer styling
        slantType: "right"
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant
        borderWidth: 1
        skewOffset: (parent.height / 2)

        Row {
            id: row
            spacing: 1
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: root.segments
                delegate: SlantedBox {
                    height: root.segment_size * 1
                    width: root.segment_size * 2

                    // Styling
                    slantType: "right"
                    skewOffset: (parent.height / 2)
                    borderWidth: 0

                    // Logic: fill if the signal strength is higher than this segment's threshold
                    // Example: Segment 1 (index 0) fills if strength > 0
                    // Segment 5 (index 4) fills if strength > 80
                    color: {
                        let threshold = (index / root.segments) * 100;
                        return (wifi.signalStrength > threshold)
                        ? root.activeColor
                        : Colors.outline
                    }

                    Behavior on color {
                        ColorAnimation { duration: 400 }
                    }
                }
            }
        }
    }

    implicitHeight: row.height + root.segment_size
    implicitWidth: row.width + (outerBox.skewOffset * 2) + root.segment_size
}
