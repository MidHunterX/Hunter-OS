import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
  id: root
  spacing: 10
  height: 8 // To accomodate numbers

  property list<int> persistentWorkspaces: [1, 2, 3]
  property int primaryLength: 70
  property int secondaryLength: 30

  property color c_focus_full: Colors.primary
  property color c_unfocus_full: Colors.secondary
  property color c_focus_empty: Colors.error
  property color c_unfocus_empty: Colors.outline
  property color c_special: "#FFFF00"
  // The human eye is most sensitive to yellowish-green light, specifically at a wavelength of 555 nanometers during daylight conditions.
  property color c_urgent: "#7CFF00"

  // Helper function to check if workspace ID is in persistent list
  function isPersistent(id) {
    for (var i = 0; i < persistentWorkspaces.length; i++) {
      if (persistentWorkspaces[i] === id) return true;
    }
    return false;
  }

  // SECTION 2: Non-persistent workspaces (dynamic)
  // Shows workspaces that exist but aren't in persistentWorkspaces,
  // but hides them if they're unfocused AND empty
  Repeater {
    model: {
      var result = [];
      for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
        var workspace = Hyprland.workspaces.values[i];
        if (root.isPersistent(workspace.id)) continue;
        if (!workspace.focused && workspace.toplevels.values.length === 0) continue;
        if (workspace.id < 0) continue; // Exclude Special Workspaces
        result.push(workspace);
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
      property bool isFocused: workspace.focused
      property bool isEmpty: workspace.toplevels.values.length === 0
      property bool isUrgent: workspace.urgent

      // BEHAVIOR: Pixel Workspace
      Rectangle {
        id: pixelWorkspaceDynamic
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        height: {
          if (isUrgent) return 4    // Urgent
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

      // TEXT: Workspace number text on top
      Text {
        anchors.centerIn: parent
        text: workspaceId
        font.pixelSize: 14
        font.bold: true
        color: isFocused ? "white" : (isEmpty ? root.c_unfocus_empty : root.c_unfocus_full)
        style: Text.Outline
        styleColor: "black"

        // TEXT: shadow for readability
        Rectangle {
          anchors.fill: parent
          color: "black"
          opacity: 0.3
          z: -1
          radius: 5
        }
      }

      Rectangle {
        anchors.fill: parent
        color: "transparent"

        // BEHAVIOR: Hover style for select
        Rectangle {
          id: hoverOverlayDynamic
          anchors.fill: parent
          color: "#bf40b9"
          opacity: 0
        }

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

      // BEHAVIOR: Click to change workspace
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { hoverOverlayDynamic.opacity = 1 }
        onExited: { hoverOverlayDynamic.opacity = 0 }
        onClicked: { Hyprland.dispatch("workspace " + workspaceId) }
      }
    }
  }
}
