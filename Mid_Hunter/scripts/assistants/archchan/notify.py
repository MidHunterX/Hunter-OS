import sys

from .notify_battery import notify_battery
from .notify_heat import notify_heat

args = sys.argv[1:]

if args[0] == "battery":
    notify_battery()

elif args[0] == "heat":
    notify_heat()
