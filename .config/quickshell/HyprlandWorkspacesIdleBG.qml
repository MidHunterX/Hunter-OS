import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
  id: root
  implicitHeight: 5
  implicitWidth: 230

  // Trigger idle state only after n seconds of inactivity
  property int inactivityTriggerSeconds: 60
  property real maxIdleMinutes: 15
  property int tickInterval: 1000


  property color c_meter_fill: Colors.primary
  property color c_meter_track: "#808080"

  property real  idleSeconds: 0
  property bool  userIsIdle: idleMonitor.isIdle

  readonly property real fillRatio: Math.min(idleSeconds / (maxIdleMinutes * 60), 1.0)

  onUserIsIdleChanged: {
    if (!userIsIdle) {
      idleSeconds = 0
    }
  }

  IdleMonitor {
    id: idleMonitor
    timeout: inactivityTriggerSeconds
  }

  Timer {
    id: idleTicker
    interval: root.tickInterval
    running: root.userIsIdle
    repeat: true
    onTriggered: root.idleSeconds += (root.tickInterval / 1000)
  }

  Row {
    anchors.fill: parent

    Item {
      id: meterSegment
      implicitWidth: root.implicitWidth
      implicitHeight: root.height
      height: root.height
      width: implicitWidth

      // Track (background)
      Rectangle {
        id: meterTrack
        anchors.fill: parent
        // radius: height / 2
        color: root.c_meter_track
        opacity: root.userIsIdle ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        // opacity: 1
      }

      // Fill (progress)
      Rectangle {
        id: meterFill
        anchors {
          left: parent.left
          top: parent.top
          bottom: parent.bottom
        }
        width: parent.width * root.fillRatio
        // radius: height / 2
        color: root.c_meter_fill

        Behavior on width {
          NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
        }
      }

      Behavior on opacity { NumberAnimation { duration: 200 } }
    }
  }
}
