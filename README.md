# Dotfiles symlinked on my machine

### install

```
figlet lolcat git tmux neovim curl wget stow tldr thefuck zellij atuin ble.sh btop yazi duf ncdu dua-cli lima-bin ncurses
```

lima-vm => a tool to manage containers

# install fzf-git [link](https://www.josean.com/posts/7-amazing-cli-tools)

```
git clone https://github.com/junegunn/fzf-git.sh.git
```

```
stow -t tmux
```

## Install with stow:

- a gnome sublink manager

```
stow .
```

###### if starship don't load

```
ln -sf ~/dotfiles/bash/starship.toml ~/.config/starship.toml
```

# export term in docker

```
export TERM=xterm-256color
```



- exec bash --login
