import time
from pathlib import Path

from common.base_assistant import BaseAssistant

# Determine the script's directory to find assets
SCRIPT_DIR = Path(__file__).parent.resolve()


class ArchChan(BaseAssistant):
    """Arch Chan persona for system monitoring."""

    def __init__(self, mood: str = "default"):
        name = "Arch Chan"
        hints = ["-h", "string:frcolor:#5cc0ff", "-h", "string:bgcolor:#1f3847"]

        # Special DP Change Logic
        if mood == "hot":
            image_path = SCRIPT_DIR / "assets/arch_hot.jpg"
        elif mood == "sad":
            image_path = SCRIPT_DIR / "assets/arch_sad.jpg"
        else:
            image_path = SCRIPT_DIR / "assets/arch_chan.jpg"

        super().__init__(name, str(image_path), hints)

    # ========================== [ MEMORY FUNCTIONS ] ========================== #
    # These are static methods because they query system state, not object state.

    @staticmethod
    def get_battery_percent() -> int:
        """Returns the current battery percentage."""
        try:
            with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
                return int(f.read().strip())
        except (FileNotFoundError, ValueError):
            return -1

    @staticmethod
    def get_battery_status() -> str:
        """Returns the current battery status (e.g., 'Charging')."""
        try:
            with open("/sys/class/power_supply/BAT0/status", "r") as f:
                return f.read().strip()
        except FileNotFoundError:
            return "Unknown"

    @staticmethod
    def get_power_draw_watts() -> float:
        """Returns the current power draw in Watts."""
        try:
            with open("/sys/class/power_supply/BAT0/power_now", "r") as f:
                micro_watts = int(f.read().strip())
                return micro_watts / 1_000_000
        except (FileNotFoundError, ValueError):
            return 0.0

    @staticmethod
    def get_cpu_percent() -> int:
        """Returns average CPU usage percentage over a 1-second interval."""
        try:
            with open("/proc/stat", "r") as f:
                line1 = f.readline()

            time.sleep(1)

            with open("/proc/stat", "r") as f:
                line2 = f.readline()

            parts1 = [int(x) for x in line1.split()[1:]]
            parts2 = [int(x) for x in line2.split()[1:]]

            cpu1, idle1 = sum(parts1), parts1[3]
            cpu2, idle2 = sum(parts2), parts2[3]

            idle_delta = idle2 - idle1
            total_delta = cpu2 - cpu1

            if total_delta == 0:
                return 0

            usage = 100 * (1 - idle_delta / total_delta)
            return int(usage)
        except (FileNotFoundError, IndexError, ValueError, ZeroDivisionError):
            return -1

    @staticmethod
    def get_cpu_temp() -> float:
        """Returns CPU temperature in degrees Celsius."""
        try:
            with open("/sys/class/thermal/thermal_zone0/temp", "r") as f:
                temp_milli_c = int(f.read().strip())
                return temp_milli_c / 1000.0
        except (FileNotFoundError, ValueError):
            return -1.0

    # =========================== [ ADMIN FUNCTIONS ] =========================== #

    def report_battery(self, override_status: str = "", override_percent: int = -1):
        """Sends a detailed battery status notification."""
        if override_percent != -1:
            battery = override_percent
        else:
            battery = self.get_battery_percent()

        if override_status != "":
            status = override_status
        else:
            status = self.get_battery_status()

        if status == "Not charging":
            meter_color = "#ffffff"
        elif status == "Charging":
            meter_color = "#8aee9f"
        elif battery >= 80:
            meter_color = "#8aee9f"
        elif battery >= 60:
            meter_color = "#def564"
        elif battery >= 40:
            meter_color = "#fbd173"
        elif battery >= 20:
            meter_color = "#ff9797"
        else:  # 0-19
            meter_color = "#fd0000"

        extra_hints = [
            "-h",
            f"string:hlcolor:{meter_color}",
            "-h",
            f"int:value:{battery}",
        ]

        if override_status:
            power_draw = self.get_power_draw_watts()
            message = f"Battery: {battery}%, is currently {override_status} at {power_draw:.1f}W"
        else:
            message = f"Battery is at {battery}%!"

        command = [
            "notify-send",
            "-i",
            self.image_path,
            *self.hints,
            *extra_hints,
            self.name,
            message,
        ]
        self._execute_command(command)
