import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../config"

Item {
    id: root
    implicitHeight: 5
    implicitWidth: 230

    // Trigger idle state only after n seconds of inactivity
    property int inactivityTriggerSeconds: 60
    property real maxIdleMinutes: 15
    property int tickInterval: 1000

    property color c_meter_fill: Colors.primary
    property color c_meter_track: Colors.outline

    property real  idleSeconds: 0
    property bool  userIsIdle: idleMonitor.isIdle
    property bool  idleDaemonRunning: false

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

    Process {
        id: idleDaemonCheck
        command: ["sh", "-c", "pgrep -x swayidle >/dev/null 2>&1 || pgrep -x hypridle >/dev/null 2>&1"]
        onExited: (exitCode, exitStatus) => {
            root.idleDaemonRunning = (exitCode === 0)
        }
    }

    Timer {
        id: daemonCheckTimer
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!idleDaemonCheck.running)
            idleDaemonCheck.running = true
        }
    }

    Row {
        anchors.fill: parent

        Item {
            id: meterSegment
            implicitWidth: root.implicitWidth
            implicitHeight: root.height
            height: root.height
            width: implicitWidth

            opacity: root.idleDaemonRunning && root.userIsIdle ? 1.0 : 0.0

            // Track (background)
            Rectangle {
                id: meterTrack
                anchors.fill: parent
                color: root.c_meter_track
                opacity: root.userIsIdle ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200 } }
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
                color: root.c_meter_fill

                Behavior on width {
                    NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
                }
            }

            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
