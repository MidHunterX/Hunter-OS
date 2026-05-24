import QtQuick
import Quickshell.Hyprland
import "../config"

Item {
    id: root

    property var workspace: null
    property int workspaceId: workspace ? workspace.id : 0
    property bool isFocused: workspace ? workspace.focused : false
    property bool isEmpty: workspace ? workspace.toplevels.values.length === 0 : true
    property bool isUrgent: workspace ? workspace.urgent : false
    property bool isSpecial: workspaceId < 0

    property bool showText: false

    property color c_focus_full: Colors.primary
    property color c_unfocus_full: Colors.secondary
    property color c_focus_empty: Colors.error
    property color c_unfocus_empty: Colors.outline
    property color c_special: "#FFFF00"
    // The human eye is most sensitive to yellowish-green light, specifically at a wavelength of 555 nanometers during daylight conditions.
    property color c_urgent: "#7CFF00"

    // BEHAVIOR: Pixel Workspace
    Rectangle {
        id: pixelWorkspace
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        height: {
            if (isUrgent) return showText ? 4 : 5
            if (isSpecial) return 3
            if (isFocused && !isEmpty) return showText ? 3 : 4
            if (!isFocused && !isEmpty) return showText ? 2 : 3
            if (isFocused && isEmpty) return 2
            return 1  // Empty Workspace
        }

        color: {
            if (isUrgent) return root.c_urgent
            if (isSpecial) return root.c_special
            if (isFocused) return isEmpty ? root.c_focus_empty : root.c_focus_full
            if (!isFocused) return isEmpty ? root.c_unfocus_empty : root.c_unfocus_full
        }

        Behavior on height { NumberAnimation { duration: 150 } }
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // TEXT: Workspace number text on top
    Text {
        visible: root.showText
        anchors.centerIn: parent
        text: root.workspaceId
        font.pixelSize: 14
        font.bold: true
        color: root.isFocused ? "white" : (root.isEmpty ? root.c_unfocus_empty : root.c_unfocus_full)
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
            id: hoverOverlay
            anchors.fill: parent
            color: "#bf40b9"
            opacity: 0
            visible: !root.isSpecial
        }

        // BEHAVIOR: Urgent blinking indicator
        Rectangle {
            id: urgentOverlay
            anchors.fill: parent
            visible: root.isUrgent
            color: "#000000"

            SequentialAnimation on opacity {
                running: root.isUrgent
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.0; duration: 500 }
                NumberAnimation { from: 0.0; to: 1.0; duration: 500 }
            }
        }
    }

    // BEHAVIOR: Click to change workspace
    MouseArea {
        anchors.fill: parent
        hoverEnabled: !root.isSpecial
        onEntered: { if (!root.isSpecial) hoverOverlay.opacity = 1 }
        onExited: { if (!root.isSpecial) hoverOverlay.opacity = 0 }
        onClicked: { if (!root.isSpecial) Hyprland.dispatch("workspace " + root.workspaceId) }
    }
}
