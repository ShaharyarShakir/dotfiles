#!/bin/bash

# Base theme directory
THEME_DIR="$HOME/dotfiles/waybar"

# Read last used profile
if [[ -f "$HOME/.cache/waybar_last_profile" ]]; then
  PROFILE=$(cat "$HOME/.cache/waybar_last_profile")
else
  echo "❌ No profile history found. Please run launch.sh first."
  exit 1
fi

CONFIG_PATH="$THEME_DIR/$PROFILE/config"
STYLE_PATH="$THEME_DIR/$PROFILE/style.css"

# Check if files exist
if [[ -f "$CONFIG_PATH" && -f "$STYLE_PATH" ]]; then
  echo "Reloading Waybar with profile: $PROFILE"
  pkill waybar
  sleep 0.5
  WAYBAR_LOG_LEVEL=trace waybar -c "$CONFIG_PATH" -s "$STYLE_PATH" &
else
  echo "❌ Config or style.css not found for $PROFILE"
  exit 1
fi

