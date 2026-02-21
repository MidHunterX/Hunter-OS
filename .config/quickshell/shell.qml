import Quickshell
import QtQuick
import Quickshell.Wayland

// Qt Docs: https://doc.qt.io/qt-6/qml-qtquick-item.html

Scope {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 10
      color: "transparent"

      Rectangle {
        anchors.fill: parent
        gradient: Gradient {
          GradientStop { position: 0.0; color: Qt.rgba(0.2, 0.2, 0.2, 0.9) }
          GradientStop { position: 1.0; color: Qt.rgba(0.2, 0.2, 0.2, 0) }
        }
      }

      Item {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        HourMeter {
          anchors.left: parent.left
        }

        HyprlandWorkspaces {
          anchors.horizontalCenter: parent.horizontalCenter
        }

        BatteryMeter {
          id: batteryMeter
          anchors.right: parent.right
        }

        /*
        IdleMeter {
          anchors.right: batteryMeter.left
          anchors.rightMargin: 20
        }
        */
      }
    }
  }

  PanelWindow {
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
      top: true
      left: true
      right: true
    }

    implicitHeight: 10
    color: "transparent"

    HyprlandWorkspacesIdleBG {
      anchors.horizontalCenter: parent.horizontalCenter
    }

  }
}
