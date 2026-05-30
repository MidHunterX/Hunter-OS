import Quickshell
import QtQuick
import Quickshell.Wayland
import "PixelUI"
import "DesktopUI"

Scope {
    PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        implicitHeight: 13

        anchors { top: true; left: true; right: true }
        margins { left: 30; right: 30 }
        color: "transparent"

        /*
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.9) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
            }
        }
        */

       MeterTime {
           anchors.left: parent.left
       }

       WorkspaceSpecial {
           anchors.right: workspaces.left
           anchors.rightMargin: 10
       }

       WorkspacePersistent {
           id: workspaces
           anchors.horizontalCenter: parent.horizontalCenter
       }

       WorkspaceOther {
           anchors.left: workspaces.right
           anchors.leftMargin: 10
       }

       MeterBattery {
           id: batteryMeter
           anchors.right: parent.right
       }
    }

    PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region {}   // click-through
        implicitHeight: 15

        anchors { top: true; left: true; right: true }
        color: "transparent"

        MeterIdle {
            // inactivityTriggerSeconds: 3
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region {}   // fully click-through
        implicitHeight: child.implicitHeight

        anchors { top: true; left: true; right: true }
        color: "transparent"

        HyprSubmap {
            id: child
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }

    PanelWindow {
        // on the desktop wallpaper
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background

        anchors { top: true; left: true; right: true }
        margins { top: 13; left: 13; right: 13 }

        implicitHeight: 35
        color: "transparent"

        ModuleTime {
            id: desktopTime
        }
        // PROXIMITY: ModuleTime
        // Wifi strength changes rapidly with Time
        ModuleWifi {
            id: desktopWifi
            anchors.left: desktopTime.right
            anchors.leftMargin: 10
            anchors.verticalCenter: desktopTime.verticalCenter
            segments: 8
        }
        // ModuleWorkspaces {} // Not that useful compared to PixelUI
        ModuleBattery {}
    }

    // Using DesktopUI/ModuleWifi instead of PixelUI/MeterWifi
    // Not enough importance to show it all times with PixelUI
    /*
    PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        mask: Region {} // click-through
        // Positioned at bottom left
        anchors { bottom: true; left: true }
        implicitWidth: wifiMeter.implicitWidth
        implicitHeight: wifiMeter.implicitHeight
        color: "transparent"
        MeterWifi {
            id: wifiMeter
        }
    }
    */
}
