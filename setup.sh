#!/usr/bin/env bash

# make a dir for config
mkdir -p ~/.config 
# install packages and source bash
chmod +x bash/install.sh
./bash/install.sh
source bash/.bashrc
# stow for creating sublinks
stow .

# link tmux in the config with home dir
ln -s ~/.tmux.conf  ~/.config/tmux/.tmux.conf
# detect if the distro arch or not
if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* ]]; then
        echo "Arch-based system detected. Running cleanup.sh..."

		chmod +x cleanup.sh
		./cleanup.sh
		  else
        echo "Not an Arch-based system. Skipping cleanup."
    fi
	else
		    echo "Skipping moving to next file."
	fi

#	curl -fsSL https://code-server.dev/install.sh | sh
