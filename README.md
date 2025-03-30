# Dotfiles symlinked on my machine
### install
```
figlet lolcat git tmux neovim curl wget stow 
```
# install fzf-git
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
######## if starship don't load 
```
ln -sf ~/dotfiles/bash/starship.toml ~/.config/starship.toml
```
