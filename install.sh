# #!/usr/bin/bash
#! /run/current-system/sw/bin/bash

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

# jetify devbox 
 if command -v devbox >/dev/null; then
	echo "devbox is already installed"
else
curl -fsSL https://get.jetify.com/devbox | bash
 fi
