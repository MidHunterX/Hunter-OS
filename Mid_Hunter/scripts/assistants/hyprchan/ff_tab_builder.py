import datetime
import json
from enum import IntEnum
from pathlib import Path
from typing import List, Optional, TypedDict, Dict, Any


class Weekday(IntEnum):
    MONDAY = 0
    TUESDAY = 1
    WEDNESDAY = 2
    THURSDAY = 3
    FRIDAY = 4
    SATURDAY = 5
    SUNDAY = 6


class ScheduleEntry(TypedDict):
    url: str
    interval_days: Optional[int]
    weekdays: Optional[List[int]]


class SequenceEntry(TypedDict):
    name: str
    urls: Optional[List[str]]
    date_map: Optional[Dict[str, str]]
    interval_days: Optional[int]


class TabScheduler:
    state_file: Path
    entries: List[ScheduleEntry]
    sequences: List[SequenceEntry]
    state: Dict[str, Any]

    def __init__(self, state_file: Optional[Path] = None):
        self.state_file = state_file or Path.home() / ".cache/run_firefox_schedule.json"
        self.entries = []
        self.sequences = []
        self._load_state()

    def daily(self, url: str):
        self.entries.append({"url": url, "interval_days": 1, "weekdays": None})
        return self

    def every_n_days(self, url: str, n: int):
        self.entries.append({"url": url, "interval_days": n, "weekdays": None})
        return self

    def weekly_on_days(self, url: str, weekdays: List[int | Weekday]):
        self.entries.append({"url": url, "interval_days": None, "weekdays": weekdays})
        return self

    def iterate_every_n_days(self, name: str, urls: List[str], n: int = 1):
        """Opens the next URL in the list every 'n' days."""
        self.sequences.append(
            {"name": name, "urls": urls, "date_map": None, "interval_days": n}
        )
        return self

    def iterate_on_dates(self, name: str, date_map: Dict[str, str]):
        """
        Opens a specific URL if today's date matches a key in the date_map.
        Format: { "2023-12-25": "https://url.com" }
        """
        self.sequences.append(
            {"name": name, "urls": None, "date_map": date_map, "interval_days": None}
        )
        return self

    def apply(self, ff_attribs: List[str]) -> None:
        today = datetime.date.today()
        today_iso = today.isoformat()
        updated = False

        for entry in self.entries:
            url = entry["url"]
            last_run_str = self.state.get(url)
            last_run = (
                datetime.date.fromisoformat(last_run_str) if last_run_str else None
            )
            due = False

            # RULE 1: INTERVAL-BASED
            if entry["interval_days"] is not None:
                if (
                    last_run is None
                    or (today - last_run).days >= entry["interval_days"]
                ):
                    due = True

            # RULE 2: WEEKDAY-BASED
            if entry["weekdays"] is not None:
                if today.weekday() in entry["weekdays"] and (last_run != today):
                    due = True

            if due:
                ff_attribs.extend(["-new-tab", url])
                self.state[url] = today_iso
                updated = True

        for seq in self.sequences:
            name = seq["name"]
            seq_state = self.state.get(name, {})

            last_run_str = seq_state.get("last_run")
            last_run = (
                datetime.date.fromisoformat(last_run_str) if last_run_str else None
            )
            index = seq_state.get("index", 0)

            url_to_open = None

            # RULE 1: INTERVAL-BASED (Sequential)
            if seq["interval_days"] is not None and seq["urls"]:
                if last_run is None or (today - last_run).days >= seq["interval_days"]:
                    url_to_open = seq["urls"][index % len(seq["urls"])]
                    index = (index + 1) % len(seq["urls"])

            # RULE 2: DATE MAP-BASED (Specific URL for Specific Date)
            elif seq["date_map"] is not None:
                if today_iso in seq["date_map"] and last_run != today:
                    url_to_open = seq["date_map"][today_iso]

            if url_to_open:
                ff_attribs.extend(["-new-tab", url_to_open])
                self.state[name] = {
                    "last_run": today_iso,
                    "index": index,
                }
                updated = True

        if updated:
            self._save_state()

    def _load_state(self) -> None:
        if self.state_file.exists():
            try:
                with open(self.state_file) as f:
                    self.state = json.load(f)
            except (json.JSONDecodeError, IOError):
                self.state = {}
        else:
            self.state = {}

    def _save_state(self) -> None:
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)
