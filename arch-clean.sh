#!/bin/bash

# Function to detect AUR helper
detect_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "yay"
    elif command -v paru &> /dev/null; then
        echo "paru"
    elif command -v trizen &> /dev/null; then
        echo "trizen"
    else
        echo "none"
    fi
}

echo "🔍 Checking disk usage..."
df -h /

echo ""
echo "📁 Top space-consuming directories in / (excluding system mounts):"
sudo du -h --max-depth=1 --exclude={"/proc","/sys","/dev","/run","/tmp"} / 2>/dev/null | sort -hr | head -n 10

echo ""
read -p "🧹 Clean pacman cache (keep last 3 versions)? (y/n): " clean_cache
if [[ "$clean_cache" == "y" ]]; then
    echo "→ Cleaning pacman cache..."
    sudo paccache -r
fi

echo ""
read -p "🧹 Remove orphaned packages? (y/n): " remove_orphans
if [[ "$remove_orphans" == "y" ]]; then
    orphans=$(pacman -Qdtq)
    if [[ ! -z "$orphans" ]]; then
        echo "→ Removing orphan packages..."
        sudo pacman -Rns $orphans
    else
        echo "→ No orphaned packages found."
    fi
fi

echo ""
read -p "🧹 Clean journal logs older than 2 weeks? (y/n): " clean_journal
if [[ "$clean_journal" == "y" ]]; then
    echo "→ Cleaning old journal logs..."
    sudo journalctl --vacuum-time=2weeks
fi

echo ""
read -p "🧹 Limit journal size to 100MB? (y/n): " limit_journal
if [[ "$limit_journal" == "y" ]]; then
    echo "→ Limiting journal size..."
    sudo journalctl --vacuum-size=100M
fi

aur_helper=$(detect_aur_helper)
echo ""
echo "🔍 Detected AUR helper: $aur_helper"

if [[ "$aur_helper" != "none" ]]; then
    read -p "🧹 Clean AUR cache for $aur_helper? (y/n): " clean_aur
    if [[ "$clean_aur" == "y" ]]; then
        echo "→ Cleaning AUR cache with $aur_helper..."
        $aur_helper -Sc --noconfirm
    fi
else
    echo "⚠️ No AUR helper found (yay, paru, or trizen)."
fi

echo ""
echo "✅ Cleanup complete. Recheck disk usage with 'df -h'."

