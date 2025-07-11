#!/bin/bash

# Battery name (support multiple batteries)
BATTERY=${1:-BAT0}
BAT_PATH="/sys/class/power_supply/$BATTERY"
THRESHOLD=15
FLAG_FILE="/tmp/waybar-${BATTERY}-low"

# Check battery exists
if [ ! -d "$BAT_PATH" ]; then
    exit 0
fi

LEVEL=$(cat "$BAT_PATH/capacity")
STATUS=$(cat "$BAT_PATH/status")

# If discharging and below threshold
if [ "$LEVEL" -le "$THRESHOLD" ] && [ "$STATUS" = "Discharging" ]; then
    if [ ! -f "$FLAG_FILE" ]; then
        notify-send -u critical "🔴 Battery Low" "Battery at ${LEVEL}% — Plug in charger!"
        canberra-gtk-play -i bell -d "battery-alert"
        touch "$FLAG_FILE"
    fi
else
    [ -f "$FLAG_FILE" ] && rm "$FLAG_FILE"
fi

