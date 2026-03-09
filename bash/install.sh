#!/usr/bin/env bash
# Print the logo
print_logo() {
	cat <<"EOF"
    ______                _ __    __
   / ____/______  _______(_) /_  / /__
  / /   / ___/ / / / ___/ / __ \/ / _ \
 / /___/ /  / /_/ / /__/ / /_/ / /  __/   Linux System Crafting Tool
 \____/_/   \__,_/\___/_/_.___/_/\___/   by: codeforge - Shaharyar Shakir

EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Define color codes using tput for better compatibility
RC=$(tput sgr0)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)

LINUXTOOLBOXDIR="$HOME/linuxtoolbox"
PACKAGER=""
SUDO_CMD=""
SUGROUP=""
GITPATH=""

# Detect distro type
# IS_ARCH: true only on real Arch Linux
# IS_NIX:  true only on real NixOS (not just a machine with nix-env installed)
IS_ARCH=false
IS_NIX=false

if [[ -f /etc/arch-release ]]; then
	IS_ARCH=true
elif [[ -f /etc/NIXOS ]] || grep -qi "nixos" /etc/os-release 2>/dev/null; then
	IS_NIX=true
fi

# Helper functions
print_colored() {
	printf "${1}%s${RC}\n" "$2"
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

check_environment() {
	REQUIREMENTS='curl groups sudo'
	for req in $REQUIREMENTS; do
		if ! command_exists "$req"; then
			print_colored "$RED" "To run me, you need: $REQUIREMENTS"
			exit 1
		fi
	done

	# Determine privilege escalation
	if command_exists sudo; then
		SUDO_CMD="sudo"
	elif command_exists doas && [ -f "/etc/doas.conf" ]; then
		SUDO_CMD="doas"
	else
		SUDO_CMD="su -c"
	fi
	printf "Using %s as privilege escalation software\n" "$SUDO_CMD"

	# Check write permissions
	GITPATH=$(dirname "$(realpath "$0")")
	if [ ! -w "$GITPATH" ]; then
		print_colored "$RED" "Can't write to $GITPATH"
		exit 1
	fi

	# Check superuser group
	SUPERUSERGROUP='wheel sudo root'
	for sug in $SUPERUSERGROUP; do
		if groups | grep -q "$sug"; then
			SUGROUP="$sug"
			printf "Super user group %s\n" "$SUGROUP"
			break
		fi
	done

	if ! groups | grep -q "$SUGROUP"; then
		print_colored "$RED" "You need to be a member of the sudo group to run me!"
		exit 1
	fi
}

# ──────────────────────────────────────────────
# HOMEBREW SETUP (default for non-Arch, non-Nix)
# ──────────────────────────────────────────────

install_homebrew() {
	if command_exists brew; then
		print_colored "$GREEN" "Homebrew is already installed."
	else
		print_colored "$YELLOW" "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		# Add brew to PATH for the current session (Linux path)
		if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		elif [[ -f "$HOME/.linuxbrew/bin/brew" ]]; then
			eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
		fi

		print_colored "$GREEN" "Homebrew installed successfully!"
	fi
}

install_from_brewfile() {
	BREWFILE="$GITPATH/Brewfile"
	if [[ ! -f "$BREWFILE" ]]; then
		print_colored "$RED" "Brewfile not found at $BREWFILE!"
		exit 1
	fi

	print_colored "$YELLOW" "Installing packages from Brewfile..."
	brew bundle --file="$BREWFILE"
	print_colored "$GREEN" "All Brewfile packages installed!"
}

# ──────────────────────────────────────────────
# ARCH LINUX (pacman + yay AUR helper)
# ──────────────────────────────────────────────

install_arch_dependencies() {
	PACKAGER="pacman"

	DEPENDENCIES='bash zsh bash-completion tar bat tree multitail fastfetch wget unzip fontconfig trash-cli make tmux starship fzf zoxide eza neovim figlet lolcat fd ripgrep yazi'

	if ! command_exists yay && ! command_exists paru; then
		print_colored "$YELLOW" "Installing yay as AUR helper..."
		${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel git
		cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
		cd yay-git && makepkg --noconfirm -si
		cd "$GITPATH"
	else
		print_colored "$GREEN" "AUR helper already installed."
	fi

	if command_exists yay; then
		AUR_HELPER="yay"
	elif command_exists paru; then
		AUR_HELPER="paru"
	else
		print_colored "$RED" "No AUR helper found. Please install yay or paru."
		exit 1
	fi

	print_colored "$YELLOW" "Installing dependencies via $AUR_HELPER..."
	${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
	print_colored "$GREEN" "Arch dependencies installed!"
}

# ──────────────────────────────────────────────
# NIX (nix-env)
# ──────────────────────────────────────────────

install_nix_dependencies() {
	print_colored "$YELLOW" "Installing dependencies via nix-env..."
	nix-env -iA \
		nixpkgs.bash \
		nixpkgs.zsh \
		nixpkgs.bash-completion \
		nixpkgs.bat \
		nixpkgs.tree \
		nixpkgs.multitail \
		nixpkgs.fastfetch \
		nixpkgs.wget \
		nixpkgs.unzip \
		nixpkgs.fontconfig \
		nixpkgs.trash-cli \
		nixpkgs.gnumake \
		nixpkgs.tmux \
		nixpkgs.starship \
		nixpkgs.fzf \
		nixpkgs.zoxide \
		nixpkgs.eza \
		nixpkgs.neovim \
		nixpkgs.figlet \
		nixpkgs.lolcat \
		nixpkgs.fd \
		nixpkgs.ripgrep \
		nixpkgs.yazi
	print_colored "$GREEN" "Nix dependencies installed!"
}

# ──────────────────────────────────────────────
# FONT INSTALLATION (all distros)
# ──────────────────────────────────────────────

install_font() {
	FONT_NAME="JetBrainsMono Nerd Font Mono"
	if fc-list :family | grep -iq "$FONT_NAME"; then
		printf "Font '%s' is already installed.\n" "$FONT_NAME"
	else
		printf "Installing font '%s'\n" "$FONT_NAME"
		FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
		FONT_DIR="$HOME/.local/share/fonts"
		if wget -q --spider "$FONT_URL"; then
			TEMP_DIR=$(mktemp -d)
			wget -q "$FONT_URL" -O "$TEMP_DIR/${FONT_NAME}.zip"
			unzip "$TEMP_DIR/${FONT_NAME}.zip" -d "$TEMP_DIR"
			mkdir -p "$FONT_DIR/$FONT_NAME"
			mv "${TEMP_DIR}"/*.ttf "$FONT_DIR/$FONT_NAME"
			fc-cache -fv
			rm -rf "${TEMP_DIR}"
			printf "'%s' installed successfully.\n" "$FONT_NAME"
		else
			printf "Font '%s' not installed. Font URL is not accessible.\n" "$FONT_NAME"
		fi
	fi
}

install_fzf_git() {
	if [[ ! -d "$HOME/fzf-git.sh" ]]; then
		git clone https://github.com/junegunn/fzf-git.sh.git "$HOME/fzf-git.sh"
	else
		print_colored "$GREEN" "fzf-git.sh already cloned."
	fi
}

# ──────────────────────────────────────────────
# CONFIG LINKING
# ──────────────────────────────────────────────

create_fastfetch_config() {
	USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
	CONFIG_DIR="$USER_HOME/.config/fastfetch"
	CONFIG_FILE="$CONFIG_DIR/config.jsonc"

	mkdir -p "$CONFIG_DIR"
	[ -e "$CONFIG_FILE" ] && rm -f "$CONFIG_FILE"

	if ! ln -svf "$GITPATH/config.jsonc" "$CONFIG_FILE"; then
		print_colored "$RED" "Failed to create symbolic link for fastfetch config"
		exit 1
	fi
}

link_config() {
	USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)
	OLD_BASHRC="$USER_HOME/.bashrc"
	BASH_PROFILE="$USER_HOME/.bash_profile"
	STARSHIP_BASH="$USER_HOME/.config/starship_bash.toml"

	if [ -e "$OLD_BASHRC" ]; then
		print_colored "$YELLOW" "Moving old bash config to $OLD_BASHRC.bak"
		mv "$OLD_BASHRC" "$OLD_BASHRC.bak" || { print_colored "$RED" "Can't move .bashrc!"; exit 1; }
	fi

	print_colored "$YELLOW" "Linking new bash config..."
	ln -svf "$GITPATH/.bashrc" "$OLD_BASHRC"

	if [ -f "$GITPATH/starship_bash.toml" ]; then
		mkdir -p "$USER_HOME/.config"
		ln -svf "$GITPATH/starship_bash.toml" "$STARSHIP_BASH"
		echo "export STARSHIP_CONFIG=\"$STARSHIP_BASH\"" >> "$OLD_BASHRC"
	fi

	if [ ! -f "$BASH_PROFILE" ]; then
		print_colored "$YELLOW" "Creating .bash_profile..."
		echo "[ -f ~/.bashrc ] && . ~/.bashrc" > "$BASH_PROFILE"
	fi
}

stow_zsh() {
	DOTFILES_DIR="$HOME/dotfiles"
	ZSHRC_PATH="$HOME/.zshrc"
	STARSHIP_SOURCE="$DOTFILES_DIR/zsh/starship_zsh.toml"
	STARSHIP_TARGET="$HOME/.config/starship_zsh.toml"

	if [ -e "$ZSHRC_PATH" ] || [ -L "$ZSHRC_PATH" ]; then
		print_colored "$YELLOW" "Backing up existing .zshrc to .zshrc.bak"
		mv -v "$ZSHRC_PATH" "$ZSHRC_PATH.bak"
	fi

	cd "$DOTFILES_DIR" || { print_colored "$RED" "Failed to enter $DOTFILES_DIR"; exit 1; }

	print_colored "$YELLOW" "Stowing zsh config..."
	if stow -t "$HOME" zsh; then
		print_colored "$GREEN" "Zsh config stowed successfully."
	else
		print_colored "$RED" "Failed to stow zsh config."
		exit 1
	fi

	if [ -f "$STARSHIP_SOURCE" ]; then
		if [ -f "$STARSHIP_TARGET" ] || [ -L "$STARSHIP_TARGET" ]; then
			print_colored "$YELLOW" "Backing up existing Starship config..."
			mv -v "$STARSHIP_TARGET" "$STARSHIP_TARGET.bak"
		fi

		ln -svf "$STARSHIP_SOURCE" "$STARSHIP_TARGET"

		if ! grep -q "STARSHIP_CONFIG" "$ZSHRC_PATH"; then
			echo "export STARSHIP_CONFIG=\"$STARSHIP_TARGET\"" >> "$ZSHRC_PATH"
		fi

		print_colored "$GREEN" "Starship config for Zsh linked and configured."
	else
		print_colored "$YELLOW" "No Starship Zsh config found at $STARSHIP_SOURCE, skipping."
	fi
}

# ──────────────────────────────────────────────
# MAIN EXECUTION
# ──────────────────────────────────────────────

check_environment

if $IS_ARCH; then
	print_colored "$YELLOW" "Detected Arch Linux — using pacman/AUR..."
	install_arch_dependencies

elif $IS_NIX; then
	print_colored "$YELLOW" "Detected Nix — using nix-env..."
	install_nix_dependencies

else
	print_colored "$YELLOW" "Using Homebrew as package manager..."
	install_homebrew
	install_from_brewfile
fi

install_font
install_fzf_git
create_fastfetch_config

if link_config && stow_zsh; then
	print_colored "$GREEN" "Done!\nRestart your shell to see the changes."
	exec bash --login
else
	print_colored "$RED" "Something went wrong!"
fi
