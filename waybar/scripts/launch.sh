#!/bin/bash

# Choose a Waybar profile
PROFILE=$(printf "default\nminimal\ndev" | wofi --dmenu --prompt "Choose Waybar Theme")

# Base path where your themes are stored
THEME_DIR="$HOME/dotfiles/waybar"

# If a profile was selected
if [[ -n "$PROFILE" ]]; then
  CONFIG_PATH="$THEME_DIR/$PROFILE/config"
  STYLE_PATH="$THEME_DIR/$PROFILE/style.css"

  # Check if files exist
  if [[ -f "$CONFIG_PATH" && -f "$STYLE_PATH" ]]; then
    echo "Launching Waybar with profile: $PROFILE"
    pkill waybar
    sleep 0.5
    WAYBAR_LOG_LEVEL=trace waybar -c "$CONFIG_PATH" -s "$STYLE_PATH" &
    
    # Save the last used profile
    echo "$PROFILE" > "$HOME/.cache/waybar_last_profile"
  else
    echo "❌ Config or style.css not found for $PROFILE"
  fi
fi

