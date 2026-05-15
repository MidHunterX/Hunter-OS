# Quickshell - Pixel UI

This status bar is designed for communication with just thin lines. This makes
sure that you get the full screen real-estate all of the time for keeping you
distraction free. The non-intrusive infomation is always there on top when you
need it and detailed information is available on desktop if that's your
intention. `#Hidden_UI: Screen borders as GUI shell interface`

## Modules

`./MeterBattery.qml` - 10 Segmented Lines denoting every 10%

`./MeterTime.qml` - 2 Segmented Meters denoting hours and minutes

`./WorkspaceSpecial.qml` + `./WorkspacePersistent.qml` + `./WorkspaceOther.qml`

Primary Priority: 3 persistent workspaces are always shown for quick
navigation. 1 = Dev Work, 2 = Personal Work, 3 = Entertainment. These three
workspaces are the most used and remapped for switching between them
efficiently and ergonomically by assigning them to three fingers in `Hyprland`.

Secondary Priority: Special Workspace indicator conditionally shown on the left
of persistent workspaces. Other workspaces conditionally shown on the right
side.

`./MeterIdle.qml`

This meter indicates the idle status of `swayidle` or `hypridle`.
Displays in the middle replacing Workspace module temporarily.
When you are idle and not using the system, the context of interaction changes.
Instead of Workspace module for quick navigation, the time remaining in Idle
daemon becomes high priority information; effectively replacing it.
