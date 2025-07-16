#!/usr/bin/bash

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
touch ~/.tmux.conf
ln -s ~/.config/tmux/.tmux.conf  ~/.tmux.conf 
# detect if the distro arch or not

#	curl -fsSL https://code-server.dev/install.sh | sh
