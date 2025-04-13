#!/bin/sh

# Script to clean pacman and AUR cache
# Based on scripts from albertored11 and luukvbaal
# https://gist.github.com/albertored11/bfc0068f4e43ca0d7ce0af968f7314db
# https://gist.github.com/luukvbaal/2c697b5e068471ee989bff8a56507142

# AUR Cache Directory - Default to yay or paru
if command -v yay &>/dev/null; then
    AUR_CACHE_DIR="$HOME/.cache/yay/"
elif command -v paru &>/dev/null; then
    AUR_CACHE_DIR="$HOME/.cache/paru/"
else
    echo "No AUR helper (yay/paru) found!"
    exit 1
fi

# Clean uninstalled AUR package caches
echo "Removing uninstalled AUR packages..."
AUR_CACHE_REMOVED="$(find "$AUR_CACHE_DIR" -maxdepth 1 -type d | awk '{ print "-c " $1 }' | tail -n +2)"
AUR_REMOVED=$(/usr/bin/paccache -ruvk0 $AUR_CACHE_REMOVED | sed '/\.cache/!d' | cut -d '\' -f2 | rev | cut -d / -f2- | rev)
[ -z "$AUR_REMOVED" ] || rm -rf $AUR_REMOVED

# Clean pacman cache - Keep latest version for uninstalled packages, keep two latest versions for installed packages
echo "Cleaning pacman cache..."
/usr/bin/paccache -qruk1
/usr/bin/paccache -qrk2 -c /var/cache/pacman/pkg "$AUR_CACHE_REMOVED"

# Optional: Clean up orphaned packages
echo "Removing orphaned packages..."
orphans=$(pacman -Qdtq)
if [ -n "$orphans" ]; then
    sudo pacman -Rns $orphans
else
    echo "No orphaned packages found."
fi

echo "Cleanup completed!"

