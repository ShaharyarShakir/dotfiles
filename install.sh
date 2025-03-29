#!/bin/bash

set -e  # Exit on any error

echo "🔍 Detecting Linux Distribution..."
OS=$(lsb_release -is 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "unknown")
echo "✅ Detected: $OS"

# Install dependencies based on distro
echo "📦 Installing required packages..."
if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo apt update && sudo apt install -y stow bat git neovim curl
elif [[ "$OS" == "arch" ]]; then
    sudo pacman -Syu --noconfirm stow bat git neovim curl
elif [[ "$OS" == "fedora" ]]; then
    sudo dnf install -y stow bat git neovim curl
else
    echo "❌ Unsupported OS. Please install packages manually."
    exit 1
fi

# Stow dotfiles (force adoption of existing files)
echo "🔗 Symlinking dotfiles using stow..."
for dir in */; do
    if [[ "$dir" != "README.md" && -d "$dir" ]]; then
        echo "🔗 Stowing $dir..."
        stow --verbose --restow --adopt "$dir"
    fi
done

# Reload shell configuration
echo "🔄 Reloading .bashrc..."
source "$HOME/.bashrc"

echo "🎉 Setup complete! Restart your terminal."

