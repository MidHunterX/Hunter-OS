import Quickshell
import QtQuick

// Qt Docs: https://doc.qt.io/qt-6/qml-qtquick-item.html

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      // Source: https://quickshell.org/docs/v0.1.0/types/Quickshell/ExclusionMode/
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 10
      color: "transparent"
      // color: "#7f7f7f"

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
          anchors.right: parent.right
        }
      }
    }
  }
}
