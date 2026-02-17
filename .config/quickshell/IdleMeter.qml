import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
  id: root
  implicitHeight: 3

  // Trigger idle state only after n seconds of inactivity
  property int inactivityTriggerSeconds: 30
  property real maxIdleMinutes: 15
  property int tickInterval: 1000

  property int meterSegmentWidth: 80

  property color c_idle_active: Colors.primary
  property color c_idle_inactive: Colors.outline
  property color c_meter_fill: Colors.primary
  property color c_meter_track: Colors.primary_container

  property real  idleSeconds: 0
  property bool  userIsIdle: idleMonitor.isIdle

  readonly property real fillRatio: Math.min(idleSeconds / (maxIdleMinutes * 60), 1.0)

  onUserIsIdleChanged: {
    if (!userIsIdle) {
      idleSeconds = 0
    }
  }

  implicitWidth: meterSegment.implicitWidth + spacing + boolSegment.implicitWidth

  property int spacing: 6

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
    spacing: root.spacing

    Item {
      id: meterSegment
      implicitWidth: root.meterSegmentWidth
      implicitHeight: root.height
      height: root.height
      width: implicitWidth

      // Track (background)
      Rectangle {
        id: meterTrack
        anchors.fill: parent
        radius: height / 2
        color: root.c_meter_track
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
        radius: height / 2
        color: root.c_meter_fill

        Behavior on width {
          NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
        }

        // Subtle pulsing glow when meter is filling
        layer.enabled: root.userIsIdle && root.fillRatio > 0
        layer.effect: null   // remove for glow shader
      }

      Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Item {
      id: boolSegment
      implicitWidth: root.height
      implicitHeight: root.height
      height: root.height
      width: implicitWidth

      Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: height / 2

        color: root.userIsIdle ? root.c_idle_active : root.c_idle_inactive

        Behavior on color {
          ColorAnimation { duration: 300 }
        }

        // Blink animation when idle
        SequentialAnimation on opacity {
          running: root.userIsIdle
          loops: Animation.Infinite
          NumberAnimation { from: 1.0; to: 0.4; duration: 700; easing.type: Easing.InOutSine }
          NumberAnimation { from: 0.4; to: 1.0; duration: 700; easing.type: Easing.InOutSine }
        }

        // Snap back to fully opaque when not idle
        opacity: root.userIsIdle ? 1.0 : 1.0
      }
    }
  }
}
