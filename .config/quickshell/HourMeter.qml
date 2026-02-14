import QtQuick
import Quickshell

Item {
  id: root
  width: 300

  property int size: 3

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  // Calculate current minute within the hour (0-59)
  property int currentMinute: clock.date.getMinutes()

  Row {
    anchors.fill: parent
    spacing: 5 // Gap in the middle

    // First half (0-30 minutes)
    Rectangle {
      width: (parent.width - parent.spacing) / 2
      height: root.size
      color: "#6b6d94"

      Rectangle {
        width: {
          if (root.currentMinute <= 30) {
            return parent.width * (root.currentMinute / 30.0)
          } else {
            return parent.width
          }
        }
        height: parent.height
        color: "#ffffff"

        Behavior on width {
          NumberAnimation { duration: 300 }
        }
      }
    }

    // Second half (30-60 minutes)
    Rectangle {
      width: (parent.width - parent.spacing) / 2
      height: root.size
      color: "#6b6d94"

      Rectangle {
        width: {
          if (root.currentMinute > 30) {
            return parent.width * ((root.currentMinute - 30) / 30.0)
          } else {
            return 0
          }
        }
        height: parent.height
        color: "#ffffff"

        Behavior on width {
          NumberAnimation { duration: 300 }
        }
      }
    }
  }
}
