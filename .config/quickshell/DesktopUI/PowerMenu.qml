import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../config"
import "../components"

PanelWindow {
    id: root

    property bool isOpen: false
    visible: isOpen || fadeOverlay.opacity > 0

    anchors { top: true; bottom: true; left: true; right: true }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    color: "transparent"

    // Background overlay with dimming effect and click-to-close
    Rectangle {
        id: fadeOverlay
        anchors.fill: parent
        color: Colors.scrim
        opacity: root.isOpen ? 0.75 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.isOpen = false
        }
    }

    Item {
        focus: root.isOpen
        Keys.onEscapePressed: root.isOpen = false
        Keys.onPressed: (event) => {
            if (!root.isOpen) return;

            switch (event.key) {
                case Qt.Key_L:
                    root.runAction(["loginctl", "lock-session"]);
                    event.accepted = true;
                    break;
                case Qt.Key_E:
                    root.runAction(["hyprctl", "dispatch", "exit"]);
                    event.accepted = true;
                    break;
                case Qt.Key_U:
                    root.runAction(["systemctl", "suspend"]);
                    event.accepted = true;
                    break;
                case Qt.Key_R:
                    root.runAction(["systemctl", "reboot"]);
                    event.accepted = true;
                    break;
                case Qt.Key_S:
                    root.runAction(["systemctl", "poweroff"]);
                    event.accepted = true;
                    break;
                case Qt.Key_W:
                    root.runAction(["kitty", "bash", "~/Mid_Hunter/scripts/sys_windows.sh"]);
                    event.accepted = true;
                    break;
            }
        }
    }

    Process { id: actionProcess }

    function runAction(commandArray) {
        root.isOpen = false
        actionProcess.running = false
        actionProcess.command = commandArray
        actionProcess.running = true
    }

    IpcHandler {
        target: "powermenu"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
    }

    Row {
        id: menuRow
        anchors.centerIn: parent

        scale: root.isOpen ? 1.0 : 0.85
        opacity: root.isOpen ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        PowerMenuButton {
            text: "Lock"
            keyBind: "L"
            icon: "󰌾"
            slantType: "left"
            onClicked: root.runAction(["loginctl", "lock-session"])
        }

        PowerMenuButton {
            text: "Logout"
            keyBind: "E"
            icon: "󰍃"
            slantType: "left"
            onClicked: root.runAction(["hyprctl", "dispatch", "exit"])
        }

        PowerMenuButton {
            text: "Shutdown"
            keyBind: "S"
            icon: "󰐥"
            slantType: "left"
            onClicked: root.runAction(["systemctl", "poweroff"])
        }

        PowerMenuButton {
            text: "Windows"
            keyBind: "W"
            icon: ""
            slantType: "right"
            onClicked: root.runAction(["systemctl", "poweroff"])
        }

        PowerMenuButton {
            text: "Reboot"
            keyBind: "R"
            icon: "󰜉"
            slantType: "right"
            onClicked: root.runAction(["systemctl", "reboot"])
        }

        PowerMenuButton {
            text: "Suspend"
            keyBind: "U"
            icon: "󰤄"
            slantType: "right"
            onClicked: root.runAction(["systemctl", "suspend"])
        }
    }
}
