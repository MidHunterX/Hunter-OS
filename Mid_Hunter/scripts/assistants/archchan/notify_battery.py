import time

from common.base_assistant import Singleton

from .persona import ArchChan


def notify_battery():
    """Monitors battery and sends notifications at intervals."""
    # Ensure only one instance of this script runs
    _ = Singleton("notify_battery")

    arch_chan = ArchChan()

    check_interval_sec = 5 * 60  # 5 minutes
    bat_notify_interval = 10  # Notify every 10%

    bat_prev = arch_chan.get_battery_percent()
    status_prev = arch_chan.get_battery_status()

    while True:
        battery = arch_chan.get_battery_percent()
        status = arch_chan.get_battery_status()

        # Detect a change in charging status (plugged/unplugged)
        status_changed = status != status_prev

        # Determine if we crossed a notification threshold
        prev_threshold = bat_prev // bat_notify_interval
        current_threshold = battery // bat_notify_interval
        threshold_crossed = prev_threshold != current_threshold

        if status_changed or threshold_crossed:
            if status == "Discharging":
                print(f"Discharging, now at {battery}%. Reporting...")
                arch_chan.report_battery("Discharging")
            elif status == "Charging":
                print(f"Charging, now at {battery}%. Reporting...")
                arch_chan.report_battery("Charging")
            else:  # Full, Not charging, etc.
                arch_chan.report_battery()

            bat_prev = battery
            status_prev = status

        time.sleep(check_interval_sec)


if __name__ == "__main__":
    notify_battery()
