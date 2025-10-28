#!/usr/bin/env python3
import datetime
import random
import subprocess
import sys
from pathlib import Path

from .persona import HyprChan

COMMENTS = [
    "I found what you're looking for. It's right here.",
    "Look no further! I've found exactly what you need.",
    "Found it! It was right here.",
    "Aha! Here's what you've been searching for.",
    "Mission accomplished! I've located what you're looking for.",
    "Found it! Here it is.",
    "Here it is! I found what you're after.",
    "The thing you're looking for is right here.",
    "Got it! I've found the item you were searching for.",
    "Search complete! I've found the missing piece.",
    "There you go! Firefox, safe and sound.",
    "Tada~! Found your Firefox, just where it was hiding.",
    "Aha! Firefox located. I'm good at this, aren't I?",
    "Gotcha! Here's your Firefox, exactly where you left it.",
    "Boom! Mission complete. Firefox is all yours.",
    "Firefox, spotted and secured! You're welcome~",
    "Easy peasy! Your Firefox has been found.",
    "Found it! Now go forth and browse!",
    "There it is! Right under our noses the whole time.",
    "Firefox retrieved! I’m basically a window-finding pro.",
    "All done~ Your Firefox is right here, ready for action.",
    "Zoom~ Found your Firefox in record time!",
    "Another job well done! Here's your Firefox.",
]


def find_firefox_process(profile_name: str) -> str | None:
    """
    Finds the PID of a running Firefox process for a given profile.
    Returns the PID as a string, or None if not found.
    """
    try:
        result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
        for line in result.stdout.strip().split("\n"):
            parts = line.strip().split(maxsplit=2)

            if len(parts) < 2:
                continue

            #    1,   2,    3,    4,   5,   6,   7,    8,     9,   10,      11
            # USER, PID, %CPU, %MEM, VSZ, RSS, TTY, STAT, START, TIME, COMMAND

            _, pid, cmd = parts

            if "firefox" in cmd and f"-P {profile_name}" in cmd:
                return pid
    except FileNotFoundError:
        print("Error: 'ps' command not found.")
    return None


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} Profile_Name")
        sys.exit(1)

    profile_name = sys.argv[1]
    hypr_chan = HyprChan()

    # Check if an instance is already running
    pid = find_firefox_process(profile_name)

    if pid:
        hypr_chan.focus_window(pid)
        hypr_chan.message(random.choice(COMMENTS), 1000)
        sys.exit(0)

    # Logic to launch a new instance
    print(f"No running instance for profile '{profile_name}'. Launching new one.")

    ff_attribs = ["-P", profile_name, "-no-remote"]

    # Logic for daily new tab for "Personal" profile
    if profile_name == "Personal":
        hist_file = Path.home() / ".cache/run_firefox_history.txt"
        today = datetime.date.today()

        last_run_date_str = ""
        if hist_file.exists():
            last_run_date_str = hist_file.read_text().strip()

        if str(today) != last_run_date_str:
            print("First run of the day for 'Personal' profile. Adding new tab.")
            ff_attribs.extend(["-new-tab", "https://app.daily.dev/"])
            hist_file.parent.mkdir(parents=True, exist_ok=True)
            hist_file.write_text(str(today))

    # Determine workspace and launch command
    workspace_cmd = []
    if profile_name == "Personal":
        workspace_cmd = ["hyprctl", "dispatch", "--", "exec", "[workspace 2]"]
    elif profile_name == "Experiment":
        workspace_cmd = ["hyprctl", "dispatch", "--", "exec", "[workspace 3]"]

    # Use Popen to run Firefox in the background
    launch_cmd = ["firefox", *ff_attribs]
    if workspace_cmd:
        # Hyprland's exec handles launching the process in the background
        subprocess.run([*workspace_cmd, *launch_cmd])
    else:
        # Fallback for other profiles without a specific workspace
        subprocess.Popen(launch_cmd)


if __name__ == "__main__":
    main()
