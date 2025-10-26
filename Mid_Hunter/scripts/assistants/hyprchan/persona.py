import json
import subprocess
from pathlib import Path

from common.base_assistant import BaseAssistant

# Determine the script's directory to find assets
SCRIPT_DIR = Path(__file__).parent.resolve()


class HyprChan(BaseAssistant):
    """Hypr Chan persona for window management tasks."""

    def __init__(self):
        name = "Hypr Chan"
        image_path = SCRIPT_DIR / "assets/hypr_chan.jpg"
        hints = ["-h", "string:frcolor:#52efb3", "-h", "string:bgcolor:#1f4738"]
        super().__init__(name, str(image_path), hints)

    # TODO: Use get_active_window for user intent detection
    @staticmethod
    def get_active_window() -> dict:
        """Gets the class and title of the active Hyprland window."""
        try:
            result = subprocess.run(
                ["hyprctl", "activewindow", "-j"],
                check=True,
                capture_output=True,
                text=True,
            )
            return json.loads(result.stdout)
        except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError):
            return {"class": "", "title": ""}
