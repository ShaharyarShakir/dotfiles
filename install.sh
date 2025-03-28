#!/bin/bash

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}🔍 Detecting Linux Distribution...${RESET}"

# Detect Linux distribution
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo -e "${RED}❌ Unsupported Linux distribution!${RESET}"
    exit 1
fi

echo -e "${GREEN}✅ Detected: $DISTRO${RESET}"

# Define package installation function
install_packages() {
    echo -e "${YELLOW}📦 Installing required packages...${RESET}"

    case "$DISTRO" in
        ubuntu | debian)
            sudo apt update && sudo apt install -y \
                git stow neovim tmux fzf ripgrep bat eza \
                zsh htop tree make gcc curl wget unzip \
                build-essential starship
            ;;
        arch)
            sudo pacman -Syu --noconfirm \
                git stow neovim tmux fzf ripgrep bat eza \
                zsh htop tree make gcc curl wget unzip \
                starship
            ;;
        fedora)
            sudo dnf install -y \
                git stow neovim tmux fzf ripgrep bat eza \
                zsh htop tree make gcc curl wget unzip \
                starship
            ;;
        *)
            echo -e "${RED}❌ Distro not supported!${RESET}"
            exit 1
            ;;
    esac
}

# Run package installation
install_packages

# Define Dotfiles Directory
DOTFILES_DIR="$HOME/dotfiles"

# Clone dotfiles repo if not already cloned
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}📂 Cloning dotfiles...${RESET}"
    git clone https://github.com/ShaharyarShakir/dotfiles.git "$DOTFILES_DIR"
else
    echo -e "${GREEN}✅ Dotfiles already exist, skipping clone.${RESET}"
fi

# Change to Dotfiles Directory
cd "$DOTFILES_DIR" || exit

# Use Stow to Symlink Dotfiles
echo -e "${YELLOW}🔗 Symlinking dotfiles using stow...${RESET}"
stow --verbose *

echo -e "${GREEN}✅ All dotfiles linked using stow!${RESET}"

# Reload shell configuration
if [[ "$SHELL" == *"zsh"* ]]; then
    echo -e "${YELLOW}🔄 Reloading .zshrc...${RESET}"
    source "$HOME/.zshrc"
else
    echo -e "${YELLOW}🔄 Reloading .bashrc...${RESET}"
    source "$HOME/.bashrc"
fi

echo -e "${GREEN}🎉 Setup complete! Restart your terminal.${RESET}"

