import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
  id: root
  spacing: 10
  height: 3

  property list<int> persistentWorkspaces: [1, 2, 3]

  property color c_focus_full: "#cdd6f4"
  property color c_unfocus_full: "#7f849c"
  property color c_focus_empty: "#ff7086"
  property color c_unfocus_empty: "#45475a"
  property color c_urgent: "#a6e3a1"

  Repeater {
    model: root.persistentWorkspaces

    Item {
      width: 70
      height: 3

      // CHECK: workspace object for this ID
      property var workspace: {
        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
          if (Hyprland.workspaces.values[i].id === modelData) {
            return Hyprland.workspaces.values[i];
          }
        }
        return null;
      }

      // CHECK: workspace state
      property bool isFocused: workspace ? workspace.focused : false
      property bool isEmpty: workspace ? workspace.toplevels.values.length === 0 : true
      property bool isUrgent: workspace ? workspace.urgent : false
      // property bool isActive: workspace ? workspace.active : false


      // BEHAVIOR: Pixel Workspace
      Rectangle {
        id: pixelWorkspace
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        height: {
          if (isUrgent) return 3    // Urgent
          if (isFocused) return 3   // Focused
          if (!isEmpty) return 2    // Non-focused non-empty
          return 1                  // Non-focused empty
        }

        color: {
          if (isUrgent) return root.c_urgent
          if (isFocused) return isEmpty ? root.c_focus_empty : root.c_focus_full
          if (!isFocused) return isEmpty ? root.c_unfocus_empty : root.c_unfocus_full
        }

        Behavior on height { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 100 } }
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"

        // BEHAVIOR: Hover style for select
        Rectangle {
          id: hoverOverlay
          anchors.fill: parent
          color: "#bf40b9"
          opacity: 0

          // gradient: Gradient {
          //   GradientStop { position: 0.0; color: Qt.rgba(0.2, 0.2, 0.2, 0.8) }
          //   GradientStop { position: 1.0; color: Qt.rgba(0.2, 0.2, 0.2, 0) }
          // }
        }

        // BEHAVIOR: Urgent blinking indicator
        Rectangle {
          id: urgentOverlay
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

      // BEHAVIOR: Click to change workspace
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { hoverOverlay.opacity = 1 }
        onExited: { hoverOverlay.opacity = 0 }
        onClicked: { Hyprland.dispatch("workspace " + modelData) }
      }
    }
  }
}
