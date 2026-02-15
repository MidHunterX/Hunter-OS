pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Expose all color properties from the adapter
    readonly property color background: fileView.adapter.background
    readonly property color error: fileView.adapter.error
    readonly property color error_container: fileView.adapter.error_container
    readonly property color inverse_on_surface: fileView.adapter.inverse_on_surface
    readonly property color inverse_primary: fileView.adapter.inverse_primary
    readonly property color inverse_surface: fileView.adapter.inverse_surface
    readonly property color on_background: fileView.adapter.on_background
    readonly property color on_error: fileView.adapter.on_error
    readonly property color on_error_container: fileView.adapter.on_error_container
    readonly property color on_primary: fileView.adapter.on_primary
    readonly property color on_primary_container: fileView.adapter.on_primary_container
    readonly property color on_primary_fixed: fileView.adapter.on_primary_fixed
    readonly property color on_primary_fixed_variant: fileView.adapter.on_primary_fixed_variant
    readonly property color on_secondary: fileView.adapter.on_secondary
    readonly property color on_secondary_container: fileView.adapter.on_secondary_container
    readonly property color on_secondary_fixed: fileView.adapter.on_secondary_fixed
    readonly property color on_secondary_fixed_variant: fileView.adapter.on_secondary_fixed_variant
    readonly property color on_surface: fileView.adapter.on_surface
    readonly property color on_surface_variant: fileView.adapter.on_surface_variant
    readonly property color on_tertiary: fileView.adapter.on_tertiary
    readonly property color on_tertiary_container: fileView.adapter.on_tertiary_container
    readonly property color on_tertiary_fixed: fileView.adapter.on_tertiary_fixed
    readonly property color on_tertiary_fixed_variant: fileView.adapter.on_tertiary_fixed_variant
    readonly property color outline: fileView.adapter.outline
    readonly property color outline_variant: fileView.adapter.outline_variant
    readonly property color primary: fileView.adapter.primary
    readonly property color primary_container: fileView.adapter.primary_container
    readonly property color primary_fixed: fileView.adapter.primary_fixed
    readonly property color primary_fixed_dim: fileView.adapter.primary_fixed_dim
    readonly property color scrim: fileView.adapter.scrim
    readonly property color secondary: fileView.adapter.secondary
    readonly property color secondary_container: fileView.adapter.secondary_container
    readonly property color secondary_fixed: fileView.adapter.secondary_fixed
    readonly property color secondary_fixed_dim: fileView.adapter.secondary_fixed_dim
    readonly property color shadow: fileView.adapter.shadow
    readonly property color surface: fileView.adapter.surface
    readonly property color surface_bright: fileView.adapter.surface_bright
    readonly property color surface_container: fileView.adapter.surface_container
    readonly property color surface_container_high: fileView.adapter.surface_container_high
    readonly property color surface_container_highest: fileView.adapter.surface_container_highest
    readonly property color surface_container_low: fileView.adapter.surface_container_low
    readonly property color surface_container_lowest: fileView.adapter.surface_container_lowest
    readonly property color surface_dim: fileView.adapter.surface_dim
    readonly property color surface_tint: fileView.adapter.surface_tint
    readonly property color surface_variant: fileView.adapter.surface_variant
    readonly property color tertiary: fileView.adapter.tertiary
    readonly property color tertiary_container: fileView.adapter.tertiary_container
    readonly property color tertiary_fixed: fileView.adapter.tertiary_fixed
    readonly property color tertiary_fixed_dim: fileView.adapter.tertiary_fixed_dim

    // Property to check if colors are loaded
    readonly property bool loaded: fileView.loaded

    property FileView fileView: FileView {
        path: {
            // Try multiple paths
            let paths = [
                Qt.resolvedUrl("./colors.json"),
                Qt.resolvedUrl("~/.config/quickshell/colors.json")
            ];

            // Return first path for now, FileView will handle the error
            return paths[0];
        }

        watchChanges: true
        onFileChanged: reload()
        printErrors: false

        onLoadFailed: function(error) {
            console.log("Colors: Failed to load - using fallback colors")
        }

        onLoaded: {
            console.log("Colors: Loaded from", path)
        }

        JsonAdapter {
            // Fallback color values (Material 3 dark theme)
            property color background: "#1a110f"
            property color error: "#ffb4ab"
            property color error_container: "#93000a"
            property color inverse_on_surface: "#392e2b"
            property color inverse_primary: "#8f4c33"
            property color inverse_surface: "#f1dfd9"
            property color on_background: "#f1dfd9"
            property color on_error: "#690005"
            property color on_error_container: "#ffdad6"
            property color on_primary: "#55200a"
            property color on_primary_container: "#ffdbcf"
            property color on_primary_fixed: "#380d00"
            property color on_primary_fixed_variant: "#72351e"
            property color on_secondary: "#442a21"
            property color on_secondary_container: "#ffdbcf"
            property color on_secondary_fixed: "#2c160d"
            property color on_secondary_fixed_variant: "#5d4036"
            property color on_surface: "#f1dfd9"
            property color on_surface_variant: "#d8c2bb"
            property color on_tertiary: "#393005"
            property color on_tertiary_container: "#f2e2a7"
            property color on_tertiary_fixed: "#221b00"
            property color on_tertiary_fixed_variant: "#50461a"
            property color outline: "#a08d86"
            property color outline_variant: "#53433e"
            property color primary: "#ffb59b"
            property color primary_container: "#72351e"
            property color primary_fixed: "#ffdbcf"
            property color primary_fixed_dim: "#ffb59b"
            property color scrim: "#000000"
            property color secondary: "#e7bdb0"
            property color secondary_container: "#5d4036"
            property color secondary_fixed: "#ffdbcf"
            property color secondary_fixed_dim: "#e7bdb0"
            property color shadow: "#000000"
            property color surface: "#1a110f"
            property color surface_bright: "#423733"
            property color surface_container: "#271d1a"
            property color surface_container_high: "#322824"
            property color surface_container_highest: "#3d322f"
            property color surface_container_low: "#231a16"
            property color surface_container_lowest: "#140c0a"
            property color surface_dim: "#1a110f"
            property color surface_tint: "#ffb59b"
            property color surface_variant: "#53433e"
            property color tertiary: "#d5c68e"
            property color tertiary_container: "#50461a"
            property color tertiary_fixed: "#f2e2a7"
            property color tertiary_fixed_dim: "#d5c68e"
        }
    }
}
