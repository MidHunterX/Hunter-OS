import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // Horizontal Mode (vertical: false):
    // "bottom" = \____/ (Pointing to bottom)
    // "top"    = /____\ (Pointing to top)
    // "left"   = \____\ (Parallelogram leaning left)
    // "right"  = /____/ (Parallelogram leaning right)
    property string slantType: "right"

    // Vertical Mode (vertical: true):
    // "right"  = Wider at right (< shape)
    // "left"   = Wider at left (> shape)
    // "top"    = Parallelogram leaning up-right (/)
    // "bottom" = Parallelogram leaning down-right (\)
    property bool vertical: false

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
            startX: (!root.vertical && (root.slantType === "bottom" || root.slantType === "right")) ? root.skewOffset : 0
            startY: (root.vertical && (root.slantType === "left" || root.slantType === "top")) ? root.skewOffset : 0

            // Top-Right Corner
            PathLine {
                x: (!root.vertical && (root.slantType === "bottom" || root.slantType === "left")) ? root.width - root.skewOffset : root.width
                y: (root.vertical && (root.slantType === "right" || root.slantType === "bottom")) ? root.skewOffset : 0
            }

            // Bottom-Right Corner
            PathLine {
                x: (!root.vertical && (root.slantType === "top" || root.slantType === "right")) ? root.width - root.skewOffset : root.width
                y: (root.vertical && (root.slantType === "right" || root.slantType === "top")) ? root.height - root.skewOffset : root.height
            }

            // Bottom-Left Corner
            PathLine {
                x: (!root.vertical && (root.slantType === "top" || root.slantType === "left")) ? root.skewOffset : 0
                y: (root.vertical && (root.slantType === "left" || root.slantType === "bottom")) ? root.height - root.skewOffset : root.height
            }

            // Close the path back to Start
            PathLine {
                x: (!root.vertical && (root.slantType === "bottom" || root.slantType === "right")) ? root.skewOffset : 0
                y: (root.vertical && (root.slantType === "left" || root.slantType === "top")) ? root.skewOffset : 0
            }
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent

        // Pad the container so text doesn't overflow into the slanted corners.
        // Dynamically applies margins to Left/Right if horizontal, or Top/Bottom if vertical.
        anchors.leftMargin: root.vertical ? 0 : root.skewOffset + 5
        anchors.rightMargin: root.vertical ? 0 : root.skewOffset + 5
        anchors.topMargin: root.vertical ? root.skewOffset + 5 : 0
        anchors.bottomMargin: root.vertical ? root.skewOffset + 5 : 0
    }
}
