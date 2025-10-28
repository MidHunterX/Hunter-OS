import os
import subprocess
from pathlib import Path


class BaseAssistant:
    """A base class for OS assistant personas."""

    def __init__(self, name: str, image_path: str, hints: list[str]):
        if not Path(image_path).is_file():
            raise FileNotFoundError(f"Image not found for {name} at: {image_path}")
        self.name = name
        self.image_path = image_path
        self.hints = hints

    def execute_command(self, command: list[str]):
        """Executes a shell command."""
        try:
            subprocess.run(command, check=True, capture_output=True, text=True)
        except FileNotFoundError:
            print(
                f"Error: Command '{command[0]}' not found. Is it installed and in your PATH?"
            )
        except subprocess.CalledProcessError as e:
            print(f"Error executing command: {' '.join(command)}")
            print(f"Stderr: {e.stderr}")

    def message(self, message_text: str, timeout: int = 5000):
        """Sends a standard notification message."""
        command = [
            "notify-send",
            "-t",
            str(timeout),
            "-i",
            self.image_path,
            *self.hints,
            self.name,
            message_text,
        ]
        self.execute_command(command)


class Singleton:
    """
    A non-thread-safe helper class to implement the singleton design pattern.
    Used to prevent multiple instances of notifier daemons from running.
    """

    def __init__(self, script_name):
        self.lock_file_path = Path(f"/tmp/{script_name}.lock")
        if self.lock_file_path.exists():
            print(f"Another instance of {script_name} is already running.")
            print(f"Lock file exists: {self.lock_file_path}")
            exit()
        self._create_lock_file()

    def _create_lock_file(self):
        import atexit

        try:
            with open(self.lock_file_path, "w") as f:
                f.write(str(os.getpid()))
            atexit.register(self.cleanup)
        except IOError as e:
            print(f"Error: Could not create lock file: {e}")
            exit(1)

    def cleanup(self):
        if self.lock_file_path.exists():
            self.lock_file_path.unlink()
