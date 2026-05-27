import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // \____/ = Bottom (BeveledEdge)
    // /____\ = Top (BeveledEdge)
    // \____\ = Left (Parallelogram)
    // /____/ = Right (Parallelogram)
    property string slantType: "right"
    property color color: "#000000"
    property color borderColor: "#ffffff"
    property int borderWidth: 1

    // Set to the following to give you the best dynamic look
    // skewOffset: (parent.height / 2)
    property real skewOffset: 15 // The pixel offset of the slant


    // The inner content assigned by the user will go into this padded container
    default property alias content: contentContainer.data

    Shape {
        id: bgShape
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            fillColor: root.color
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth
            joinStyle: ShapePath.RoundJoin

            // Top-Left Starting Point
            startX: (root.slantType === "bottom" || root.slantType === "left") ? root.skewOffset : 0
            startY: 0

            // Top-Right Corner
            PathLine {
                x: (root.slantType === "bottom" || root.slantType === "right") ? root.width - root.skewOffset : root.width
                y: 0
            }

            // Bottom-Right Corner
            PathLine {
                x: (root.slantType === "top" || root.slantType === "left") ? root.width - root.skewOffset : root.width
                y: root.height
            }

            // Bottom-Left Corner
            PathLine {
                x: (root.slantType === "top" || root.slantType === "right") ? root.skewOffset : 0
                y: root.height
            }

            // Close the path back to Start
            PathLine {
                x: (root.slantType === "bottom" || root.slantType === "left") ? root.skewOffset : 0
                y: 0
            }
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        // Pad the container so text doesn't overflow into the slanted corners
        anchors.leftMargin: root.skewOffset + 5
        anchors.rightMargin: root.skewOffset + 5
    }
}
