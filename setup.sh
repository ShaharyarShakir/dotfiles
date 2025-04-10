#!/usr/bin/env bash
mkdir -p ~/.config 
stow .
chmod +x bash/install.sh
./bash/install.sh
soource /bash/.bashrc

ln -s ~/.tmux.conf  ~/.config/tmux/.tmux.conf
