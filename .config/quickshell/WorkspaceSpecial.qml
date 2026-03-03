import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
  id: root
  spacing: 10
  height: 8 // To accomodate numbers

  property int primaryLength: 70
  property int secondaryLength: 30

  property color c_special: "#FFFF00"
  property color c_urgent: "#7CFF00"

  Repeater {
    model: {
      var result = [];
      for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
        var workspace = Hyprland.workspaces.values[i];
        if (workspace.id < 0) result.push(workspace);
      }
      // Sort by ID to maintain order
      result.sort(function(a, b) { return a.id - b.id; });
      return result;
    }

    Item {
      width: root.secondaryLength
      height: root.height

      // Direct reference to workspace object from model
      property var workspace: modelData
      property int workspaceId: workspace.id

      // CHECK: workspace state
      property bool isUrgent: workspace.urgent
      property bool isSpecial: workspaceId < 0

      // BEHAVIOR: Pixel Workspace
      Rectangle {
        id: pixelWorkspaceDynamic
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        height: {
          if (isUrgent) return 4    // Urgent
          return 3                  // Special
        }

        color: {
          if (isUrgent) return root.c_urgent
          if (isSpecial) return root.c_special
        }

        Behavior on height { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 100 } }
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"

        // BEHAVIOR: Urgent blinking indicator
        Rectangle {
          id: urgentOverlayDynamic
          anchors.fill: parent
          visible: isUrgent
          color: "#000000"

          SequentialAnimation on opacity {
            running: isUrgent
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.0; duration: 500 }
            NumberAnimation { from: 0.0; to: 1.0; duration: 500 }
          }
        }
      }
    }
  }
}
