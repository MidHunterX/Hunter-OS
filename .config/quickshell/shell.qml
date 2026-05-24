import Quickshell
import QtQuick
import Quickshell.Wayland
import "config"     // Global Config
import "components" // Reuseable Unit Components
import "PixelUI"
import "DesktopUI"

// Qt Docs: https://doc.qt.io/qt-6/qml-qtquick-item.html

Scope {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Bottom
            implicitHeight: 15

            anchors { top: true; left: true; right: true }
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.9) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
                }
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

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
        }
    }

    PanelWindow {
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay

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

        anchors { bottom: true; left: true; right: true }
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
        margins { top: 15; left: 10; right: 10 }

        implicitHeight: 35
        color: "transparent"

        ModuleTime {}
        // ModuleWorkspaces {} // Not that useful compared to PixelUI
        ModuleBattery {}
    }
}
