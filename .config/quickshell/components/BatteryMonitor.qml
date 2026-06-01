import QtQuick
import Quickshell.Services.UPower
// Quickshell.Services.UPower module binds directly to the system's UPower DBus daemon

Item {
    id: root
    readonly property int batteryPercent: {
        let bat = UPower.devices.values.find(d => d.isLaptopBattery);
        return bat ? Math.round(bat.percentage * 100) : 0; // percentage is 0.0 to 1.0
    }

    readonly property bool isCharging: {
        let bat = UPower.devices.values.find(d => d.isLaptopBattery);
        return bat ? (bat.state === UPowerDeviceState.Charging) : false;
    }
}
