# dotfiles how to install
- clone this repo cd into this repo
# install these packages
```
pacman -S vim bat fzf git curl wget unzip zip lazygit gitui tmux neovim
```

```
# use stow to source them
stow -d ~/dotfiles -t ~ bash nvim zsh
```

# install starship
```
curl -sS https://starship.rs/install.sh | sh
```

