import QtQuick
import Quickshell.Io

Item {
    id: root
    property int signalStrength: 0
    property bool isOnline: false

    property int intervalWifiStrength: 10000
    property int intervalInternetConnection: 30000

    // Fetches signal strength (0-100)
    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f SIGNAL,ACTIVE device wifi | grep 'yes$' | cut -d: -f1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var strength = parseInt(this.text.trim())
                root.signalStrength = isNaN(strength) ? 0 : strength
            }
        }
    }

    // Checks for actual internet access
    Process {
        id: netCheckProc
        command: ["nmcli", "networking", "connectivity", "check"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var status = this.text.trim()
                // status can be: full, limited, portal, none, unknown
                root.isOnline = (status === "full")
            }
        }
    }

    Timer {
        interval: root.intervalWifiStrength
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            wifiProc.running = true
        }
    }

    Timer {
        interval: root.intervalInternetConnection
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netCheckProc.running = true
        }
    }
}
