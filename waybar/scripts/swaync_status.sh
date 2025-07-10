#!/bin/bash

CACHE_FILE="/tmp/waybar-notify-last-count"
UNREAD=$(swaync-client -c)
COUNT=$(echo "$UNREAD" | jq '. | length')

# Get previous count
PREV_COUNT=0
if [ -f "$CACHE_FILE" ]; then
  PREV_COUNT=$(<"$CACHE_FILE")
fi

# Save current count
echo "$COUNT" > "$CACHE_FILE"

# Play sound if new notification arrives
if [ "$COUNT" -gt "$PREV_COUNT" ]; then
  canberra-gtk-play -i bell -d "waybar-notification"
fi

# Output JSON for waybar
if [ "$COUNT" -gt 0 ]; then
  echo "{\"text\": \"󰍡 $COUNT\", \"tooltip\": false, \"class\": \"notify\"}"
else
  echo "{\"text\": \"󰂚\", \"tooltip\": false, \"class\": \"empty\"}"
fi

