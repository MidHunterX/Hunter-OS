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
    urls: List[str]
    interval_days: Optional[int]
    specific_dates: Optional[List[datetime.date]]


class TabScheduler:
    state_file: Path
    entries: List[ScheduleEntry]
    sequences: List[SequenceEntry]
    state: Dict[str, Any]

    def __init__(self, state_file: Optional[Path] = None):
        self.state_file = state_file or Path.home() / ".cache/run_firefox_schedule.json"
        # each entry: {'url': str, 'interval_days': int or None, 'weekdays': list or None}
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
            {"name": name, "urls": urls, "interval_days": n, "specific_dates": None}
        )
        return self

    def iterate_on_dates(self, name: str, urls: List[str], dates: List[datetime.date]):
        """
        Opens the next URL in the list when today matches a specific date.
        """
        self.sequences.append(
            {"name": name, "urls": urls, "interval_days": None, "specific_dates": dates}
        )
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

        for seq in self.sequences:
            name = seq["name"]
            urls = seq["urls"]
            if not urls:
                continue

            seq_state = self.state.get(name, {})
            if isinstance(seq_state, str):
                seq_state = {"last_run": seq_state, "index": 0}

            last_run_str = seq_state.get("last_run")
            last_run = (
                datetime.date.fromisoformat(last_run_str) if last_run_str else None
            )
            index = seq_state.get("index", 0)

            due = False

            # RULE 1: INTERVAL-BASED
            if seq["interval_days"] is not None:
                if last_run is None:
                    due = True
                else:
                    if (today - last_run).days >= seq["interval_days"]:
                        due = True

            # RULE 2: SPECIFIC DATES
            if seq["specific_dates"] is not None:
                not_run_today = last_run is None or last_run != today
                if today in seq["specific_dates"] and not_run_today:
                    due = True

            if due:
                url_to_open = urls[index % len(urls)]
                ff_attribs.extend(["-new-tab", url_to_open])

                self.state[name] = {
                    "last_run": today.isoformat(),
                    "index": (index + 1) % len(urls),
                }
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
