# Dotfiles symlinked on my machine
### install
```
figlet lolcat git tmux neovim curl wget stow tldr thefuck zellij
```
# install fzf-git [link](https://www.josean.com/posts/7-amazing-cli-tools)
```
git clone https://github.com/junegunn/fzf-git.sh.git
```
```
stow -t tmux
```
## Install with stow:

```
stow .
```

###### if starship don't load 

```
ln -sf ~/dotfiles/bash/starship.toml ~/.config/starship.toml
```
