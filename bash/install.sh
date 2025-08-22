# #!/bin/bash
#! /run/current-system/sw/bin/bash


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

# Helper functions
print_colored() {
	printf "${1}%s${RC}\n" "$2"
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

check_environment() {
	# Check for required commands
	REQUIREMENTS='curl groups sudo'
	for req in $REQUIREMENTS; do
		if ! command_exists "$req"; then
			print_colored "$RED" "To run me, you need: $REQUIREMENTS"
			exit 1
		fi
	done

	# Determine package manager
	if [[ "$OS_TYPE" == "Darwin" ]]; then
		if ! command_exists brew; then
			print_colored "$YELLOW" "Installing Homebrew..."
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		fi

		PACKAGER="brew"
	else
		PACKAGEMANAGER='nala apt dnf yum pacman zypper emerge xbps-install nix-env apk'
		for pgm in $PACKAGEMANAGER; do
			if command_exists "$pgm"; then
				PACKAGER="$pgm"
				printf "Using %s\n" "$pgm"
				break
			fi
		done
	fi
	if [ -z "$PACKAGER" ]; then
		print_colored "$RED" "Can't find a supported package manager"
		exit 1
	fi

	# Determine sudo command
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

install_dependencies() {
	DEPENDENCIES='bash zsh bash-completion tar bat tree multitail fastfetch wget unzip fontconfig trash-cli make tmux'
	if ! command_exists nvim; then
		DEPENDENCIES="${DEPENDENCIES} neovim"
	fi

	print_colored "$YELLOW" "Installing dependencies..."
	case "$PACKAGER" in
	pacman)
		install_pacman_dependencies
		;;
	nala)
		"${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}"
		;;
	apk)
		"${SUDO_CMD} ${PACKAGER} add --no-cache ${DEPENDENCIES}"
		;;
	emerge)
		"${SUDO_CMD} ${PACKAGER} -v app-shells/bash app-shells/bash-completion app-arch/tar app-editors/neovim sys-apps/bat app-text/tree app-text/multitail app-misc/fastfetch app-misc/trash-cli"
		;;
	xbps-install)
		"${SUDO_CMD} ${PACKAGER} -v ${DEPENDENCIES}"
		;;
	nix-env)
		"${SUDO_CMD} ${PACKAGER} -iA nixos.bash nixos.bash-completion nixos.gnutar nixos.neovim nixos.bat nixos.tree nixos.multitail nixos.fastfetch nixos.pkgs.starship nixos.trash-clii"
		;;
	dnf)
		${SUDO_CMD} ${PACKAGER} install -y ${DEPENDENCIES}
		;;
	zypper)
		${SUDO_CMD} ${PACKAGER} install -n ${DEPENDENCIES}
		;;
	*)
		${SUDO_CMD} ${PACKAGER} install -yq ${DEPENDENCIES}
		;;
	esac

	install_font
}

install_pacman_dependencies() {
	if ! command_exists yay && ! command_exists paru; then
		printf "Installing yay as AUR helper...\n"
		${SUDO_CMD} ${PACKAGER} --noconfirm -S base-devel
		cd /opt && ${SUDO_CMD} git clone https://aur.archlinux.org/yay-git.git && ${SUDO_CMD} chown -R "${USER}:${USER}" ./yay-git
		cd yay-git && makepkg --noconfirm -si
	else
		printf "AUR helper already installed\n"
	fi
	if command_exists yay; then
		AUR_HELPER="yay"
	elif command_exists paru; then
		AUR_HELPER="paru"
	else
		printf "No AUR helper found. Please install yay or paru.\n"
		exit 1
	fi
	${AUR_HELPER} --noconfirm -S ${DEPENDENCIES}
}

install_font() {
	FONT_NAME="JetBrainsMono Nerd Font Mono"
	if fc-list :family | grep -iq "$FONT_NAME"; then
		printf "Font '%s' is installed.\n" "$FONT_NAME"
	else
		printf "Installing font '%s'\n" "$FONT_NAME"
		FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
		FONT_DIR="$HOME/.local/share/fonts"
		if wget -q --spider "$FONT_URL"; then
			TEMP_DIR=$(mktemp -d)
			wget -q "$FONT_URL" -O "$TEMP_DIR"/"${FONT_NAME}.zip"
			unzip "$TEMP_DIR"/"${FONT_NAME}.zip" -d "$TEMP_DIR"
			mkdir -p "$FONT_DIR"/"$FONT_NAME"
			mv "${TEMP_DIR}"/*.ttf "$FONT_DIR"/"$FONT_NAME"
			# Update the font cache
			fc-cache -fv
			rm -rf "${TEMP_DIR}"
			printf "'%s' installed successfully.\n" "$FONT_NAME"
		else
			printf "Font '%s' not installed. Font URL is not accessible.\n" "$FONT_NAME"
		fi
	fi
}

install_starship_and_fzf() {
	if ! command_exists starship; then
		if ! curl -sS https://starship.rs/install.sh | sh; then
			print_colored "$RED" "Something went wrong during starship install!"
			exit 1
		fi
	else
		printf "Starship already installed\n"
	fi

	if ! command_exists fzf; then
		if [ -d "$HOME/.fzf" ]; then
			print_colored "$YELLOW" "FZF directory already exists. Skipping installation."
		else
			git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
			~/.fzf/install
		fi
	else
		printf "Fzf already installed\n"
	fi
}

install_zoxide() {
	if ! command_exists zoxide; then
		if ! curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
			print_colored "$RED" "Something went wrong during zoxide install!"
			exit 1
		fi
	else
		printf "Zoxide already installed\n"
	fi
}

install_tmux() {
	if ! command_exists tmux; then
		print_colored "$YELLOW" "Installing Tmux..."
		${SUDO_CMD} ${PACKAGER} install tmux

		print_colored "$GREEN" "Tmux installed successfully!"
	else
		print_colored "$GREEN" "Tmux is already installed."
	fi
}
install_kitty() {
	if ! command_exists tmux; then
		print_colored "$YELLOW" "Installing Kitty ghostty ..."
		${SUDO_CMD} ${PACKAGER} kitty ghostty

		print_colored "$GREEN" "Kitty ghostty installed successfully!"
	else
		print_colored "$GREEN" "Kitty ghostty is already installed."
	fi
}

install_neovim() {
	if ! command_exists nvim; then
		print_colored "$YELLOW" "Installing Neovim..."

		case "$PACKAGER" in
		apk)
			${SUDO_CMD} apk add --no-cache neovim
			;;
		apt | nala)
			${SUDO_CMD} ${PACKAGER} install -y neovim
			;;
		dnf | yum)
			${SUDO_CMD} ${PACKAGER} install -y neovim
			;;
		pacman)
			${SUDO_CMD} ${PACKAGER} -Sy --noconfirm neovim
			;;
		zypper)
			${SUDO_CMD} ${PACKAGER} install -y neovim
			;;
		xbps-install)
			${SUDO_CMD} ${PACKAGER} -Sy neovim
			;;
		nix-env)
			${SUDO_CMD} nix-env -iA nixpkgs.neovim
			;;
		*)
			print_colored "$RED" "Unsupported or unknown package manager: $PACKAGER"
			return 1
			;;
		esac

		print_colored "$GREEN" "Neovim installed successfully!"
	else
		print_colored "$GREEN" "Neovim is already installed."
	fi
}

install_figlet_and_lolcat() {
	if ! command_exists figlet || ! command_exists lolcat; then
		print_colored "$YELLOW" "Installing Figlet and Lolcat..."

		case "$PACKAGER" in
		apk)
			${SUDO_CMD} apk add --no-cache figlet ruby ruby-dev build-base
			${SUDO_CMD} gem install lolcat
			;;
		apt | nala)
			${SUDO_CMD} ${PACKAGER} install -y figlet lolcat
			;;
		dnf | yum)
			${SUDO_CMD} ${PACKAGER} install -y figlet lolcat
			;;
		pacman)
			${SUDO_CMD} ${PACKAGER} -Sy --noconfirm figlet lolcat
			;;
		zypper)
			${SUDO_CMD} ${PACKAGER} install -y figlet lolcat
			;;
		xbps-install)
			${SUDO_CMD} ${PACKAGER} -Sy figlet lolcat
			;;
		nix-env)
			${SUDO_CMD} nix-env -iA nixpkgs.figlet nixpkgs.lolcat
			;;
		*)
			print_colored "$RED" "Unsupported or unknown package manager: $PACKAGER"
			return 1
			;;
		esac

		print_colored "$GREEN" "Figlet and Lolcat installed successfully!"
	else
		print_colored "$GREEN" "Figlet and Lolcat are already installed."
	fi
}

install_eza() {
	if ! command_exists eza; then
		print_colored "$YELLOW" "Installing eza (ls replacement)..."

		case "$PACKAGER" in
		apt) ${SUDO_CMD} apt install -y eza || ${SUDO_CMD} apt install -y exa ;;
		apk) ${SUDO_CMD} apk add --no-cache eza || ${SUDO_CMD} apk add --no-cache exa ;;
		dnf) ${SUDO_CMD} dnf install -y eza || ${SUDO_CMD} dnf install -y exa ;;
		yum) ${SUDO_CMD} yum install -y eza || ${SUDO_CMD} yum install -y exa ;;
		pacman) ${SUDO_CMD} pacman -S --noconfirm eza || ${SUDO_CMD} pacman -S --noconfirm exa ;;
		zypper) ${SUDO_CMD} zypper install -y eza || ${SUDO_CMD} zypper install -y exa ;;
		brew) brew install eza || brew install exa ;; # macOS/Homebrew
		*) print_colored "$RED" "Unsupported package manager: $PACKAGER" && return 1 ;;
		esac

		print_colored "$GREEN" "eza installed successfully!"
	else
		print_colored "$GREEN" "eza is already installed."
	fi
}

install_yazi() {
	if command -v yazi &>/dev/null || command -v ranger &>/dev/null || command -v nnn &>/dev/null; then
		print_colored "$GREEN" "Yazi, Ranger, or nnn is already installed!"
		return
	fi

	print_colored "$YELLOW" "Installing terminal file managers..."

	case "$PACKAGER" in
	pacman)
		print_colored "$YELLOW" "Installing on Arch Linux..."
		${SUDO_CMD} pacman -Sy --noconfirm yazi ffmpeg imagemagick
		;;
	apt | nala)
		print_colored "$YELLOW" "Installing on Debian/Ubuntu..."
		${SUDO_CMD} apt update && ${SUDO_CMD} apt install -y cargo ffmpeg imagemagick
		cargo install yazi-fm
		;;
	dnf | yum)
		print_colored "$YELLOW" "Installing on Fedora..."
		${SUDO_CMD} dnf install -y cargo ffmpeg imagemagick
		cargo install yazi-fm
		;;
	apk)
		print_colored "$YELLOW" "Installing on Alpine Linux..."
		${SUDO_CMD} apk update
		${SUDO_CMD} apk add ranger nnn ffmpeg imagemagick
		;;
	*)
		print_colored "$RED" "Unsupported or unknown package manager: $PACKAGER"
		return 1
		;;
	esac

	print_colored "$GREEN" "Terminal file manager installation complete!"
}
install_fd() {
	if command -v yazi &>/dev/null; then
		print_colored "$GREEN" "Yazi is already installed!"
		return
	fi

	print_colored "$YELLOW" "Installing Yazi and dependencies..."

	if [[ -f /etc/arch-release ]]; then
		print_colored "$" "Installing on Arch Linux..."
		sudo pacman -Sy --noconfirm p7zip jq poppler fd ripgrep

	elif [[ -f /etc/debian_version ]]; then
		print_colored "$YELLOW" "Installing on Debian/Ubuntu..."
		sudo apt update && sudo apt install -y cargo p7zip jq poppler-utils fd-find ripgrep

	elif [[ -f /etc/fedora-release ]]; then
		print_colored "$YELLOW" "Installing on Fedora..."
		sudo dnf install -y cargo p7zip jq poppler fd-find ripgrep
	elif [[ -f /etc/alpine-release ]]; then
		print_colored "$YELLOW" "Installing on Alpine Linux..."
		sudo apk update
		sudo apk add p7zip jq poppler-utils fd ripgrep
	else
		print_colored "$RED" "Unsupported OS!"
		return 1
	fi

	print_colored "$GREEN" "Yazi installation complete!"
}
install_fzf_git() {
	git clone https://github.com/junegunn/fzf-git.sh.git
	mv fzf-git.sh ~/

}

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

    # Backup old bashrc
    if [ -e "$OLD_BASHRC" ]; then
        print_colored "$YELLOW" "Moving old bash config to $OLD_BASHRC.bak"
        mv "$OLD_BASHRC" "$OLD_BASHRC.bak" || { print_colored "$RED" "Can't move .bashrc!"; exit 1; }
    fi

    # Link new bashrc
    print_colored "$YELLOW" "Linking new bash config..."
    ln -svf "$GITPATH/.bashrc" "$OLD_BASHRC"

    # Link Starship Bash config
    if [ -f "$GITPATH/starship_bash.toml" ]; then
        mkdir -p "$USER_HOME/.config"
        ln -svf "$GITPATH/starship_bash.toml" "$STARSHIP_BASH"
        echo "export STARSHIP_CONFIG=\"$STARSHIP_BASH\"" >> "$OLD_BASHRC"
    fi

    # Create .bash_profile if missing
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

    # Backup existing .zshrc
    if [ -e "$ZSHRC_PATH" ] || [ -L "$ZSHRC_PATH" ]; then
        print_colored "$YELLOW" "Backing up existing .zshrc to .zshrc.bak"
        mv -v "$ZSHRC_PATH" "$ZSHRC_PATH.bak"
    fi


    # Enter dotfiles directory
    cd "$DOTFILES_DIR" || { print_colored "$RED" "Failed to enter $DOTFILES_DIR"; exit 1; }

    # Stow zsh config
    print_colored "$YELLOW" "Stowing zsh config..."
    if stow -t "$HOME" zsh; then
        print_colored "$GREEN" "Zsh config stowed successfully."
    else
        print_colored "$RED" "Failed to stow zsh config."
        exit 1
    fi

    # Link Starship Zsh config
    if [ -f "$STARSHIP_SOURCE" ]; then
        # Backup old config if exists
        if [ -f "$STARSHIP_TARGET" ] || [ -L "$STARSHIP_TARGET" ]; then
            print_colored "$YELLOW" "Backing up existing Starship config to starship_zsh.toml.bak"
            mv -v "$STARSHIP_TARGET" "$STARSHIP_TARGET.bak"
        fi

        # Link new Starship config
        ln -svf "$STARSHIP_SOURCE" "$STARSHIP_TARGET"

        # Add STARSHIP_CONFIG to .zshrc if not already present
        if ! grep -q "STARSHIP_CONFIG" "$ZSHRC_PATH"; then
            echo "export STARSHIP_CONFIG=\"$STARSHIP_TARGET\"" >> "$ZSHRC_PATH"
        fi

        print_colored "$GREEN" "Starship config for Zsh linked and configured."
    else
        print_colored "$YELLOW" "No Starship Zsh config found at $STARSHIP_SOURCE, skipping."
    fi
}
# Main execution
# setup_directories
check_environment
install_dependencies
install_starship_and_fzf
install_zoxide
install_neovim
# install_figlet_and_lolcat
install_kitty
install_eza
install_yazi
install_fd
create_fastfetch_config
link_config
stow_zsh

if link_config; then
	print_colored "$GREEN" "Done!\nrestart your shell to see the changes."
	exec bash --login
else
	print_colored "$RED" "Something went wrong!"
fi
