import QtQuick
import "../config"
import "../components"

Item {
    id: root

    // UI Configuration
    property int segments: 8
    property int segment_size: 8
    property int max_brightness_threshold: 100

    readonly property color activeColor: Colors.secondary
    readonly property color inactiveColor: Colors.secondary_container

    BrightnessMonitor {
        id: monitor
    }

    SlantedBox {
        id: outerBox
        anchors.fill: parent

        slantType: "left"
        color: Colors.surface_container_highest
        borderColor: Colors.outline_variant
        borderWidth: 1
        skewOffset: (parent.height / 2)

        Row {
            id: contentContainer
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: icon
                text: "󰃠"
                color: Colors.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                id: row
                spacing: 1
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: root.segments
                    delegate: SlantedBox {
                        height: root.segment_size * 1
                        width: root.segment_size * 2

                        slantType: "left"
                        skewOffset: (parent.height / 2)
                        borderWidth: 0

                        // Logic: fill segment if brightness is above threshold
                        color: {
                            let threshold = (index / root.segments) * root.max_brightness_threshold;
                            return (monitor.brightness > threshold)
                            ? root.activeColor
                            : root.inactiveColor
                        }

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }
                }
            }

            Text {
                id: text
                text: monitor.brightness + "%"
                color: Colors.on_surface_variant
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    implicitHeight: row.height + root.segment_size
    implicitWidth: contentContainer.width + (outerBox.skewOffset * 2) + root.segment_size
}
