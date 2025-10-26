import time

from common.base_assistant import Singleton

from .persona import ArchChan


def notify_heat():
    """Monitors CPU temperature and sends a warning if it's too high."""
    # Ensure only one instance of this script runs
    _ = Singleton("notify_heat")

    arch_chan = ArchChan(mood="hot")

    check_interval_sec = 5 * 60  # 5 minutes
    warm_temp_c = 70.0

    print("Starting CPU heat monitoring...")

    while True:
        cpu_temp = arch_chan.get_cpu_temp()

        if cpu_temp > warm_temp_c:
            print(f"CPU is hot! Temp: {cpu_temp:.1f}°C. Notifying...")
            arch_chan.message(
                f"CPU TEMP @ {cpu_temp:.1f}°C. Getting a little bit hot in here."
            )

        time.sleep(check_interval_sec)


if __name__ == "__main__":
    notify_heat()
