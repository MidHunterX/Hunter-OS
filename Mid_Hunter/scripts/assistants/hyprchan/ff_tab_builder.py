import datetime
import json
from enum import IntEnum
from pathlib import Path
from typing import List, Optional, TypedDict, Dict


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


class TabScheduler:
    state_file: Path
    entries: List[ScheduleEntry]
    state: Dict[str, str]

    def __init__(self, state_file: Optional[Path] = None):
        self.state_file = state_file or Path.home() / ".cache/run_firefox_schedule.json"
        # each entry: {'url': str, 'interval_days': int or None, 'weekdays': list or None}
        self.entries = []
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

    def apply(self, ff_attribs: List[str]) -> None:
        today = datetime.date.today()
        updated = False

        for entry in self.entries:
            url = entry["url"]
            last_run_str = self.state.get(url)
            last_run = None
            if last_run_str:
                last_run = datetime.date.fromisoformat(last_run_str)
            due = False

            # RULE 1: INTERVAL-BASED
            if entry["interval_days"] is not None:
                if last_run is None:
                    due = True
                else:
                    days_since = (today - last_run).days
                    if days_since >= entry["interval_days"]:
                        due = True

            # RULE 2: WEEKDAY-BASED
            if entry["weekdays"] is not None:
                not_run_today = last_run is None or last_run != today
                if today.weekday() in entry["weekdays"] and not_run_today:
                    due = True

            if due:
                ff_attribs.extend(["-new-tab", url])
                self.state[url] = today.isoformat()
                updated = True

        if updated:
            self._save_state()

    def _load_state(self) -> None:
        if self.state_file.exists():
            try:
                with open(self.state_file) as f:
                    self.state = json.load(f)
            except json.JSONDecodeError:
                self.state = {}
        else:
            self.state = {}

    def _save_state(self) -> None:
        self.state_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.state_file, "w") as f:
            json.dump(self.state, f, indent=2)
