import sys
import time
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from common.base_assistant import Singleton

from archchan.persona import MOODS, ArchChan


def notify_heat():
    """Monitors CPU temperature and sends a warning if it's too high."""
    # Ensure only one instance of this script runs
    _ = Singleton("notify_heat")

    arch_chan = ArchChan(mood=MOODS.HOT)

    check_interval_sec = 5 * 60  # 5 minutes
    warm_temp_c = 70.0

    print("Starting CPU heat monitoring...")

    while True:
        cpu_temp = arch_chan.get_cpu_temp()

        if cpu_temp > warm_temp_c:
            top_procs = arch_chan.get_top_cpu_processes(n=2)

            process_info = ""
            if top_procs:
                process_info = "- " + "\n- ".join(top_procs)

            process_log = ", ".join(top_procs)
            print(f"CPU Temp: {cpu_temp:.1f}°C. Processes: {process_log}")

            message = (
                f"CPU TEMP: {cpu_temp:.1f}°C.\n" f"Source of heat:\n{process_info}"
            )

            arch_chan.message(message)

        time.sleep(check_interval_sec)


if __name__ == "__main__":
    notify_heat()
