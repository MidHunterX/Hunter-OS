import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property color color: "#000000"
  property color borderColor: "#ffffff"
  property int borderWidth: 1
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

      // Draws the /____/ parallelogram shape
      startX: root.skewOffset; startY: 0
      PathLine { x: root.width; y: 0 }
      PathLine { x: root.width - root.skewOffset; y: root.height }
      PathLine { x: 0; y: root.height }
      PathLine { x: root.skewOffset; y: 0 }
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
