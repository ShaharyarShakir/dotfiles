# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
# alias vi='nvim'
# export MAVEN_OPTS="--enable-native-access=ALL-UNNAMED"
FLAG_FILE="/tmp/fastfetch_ran_$USER"
# Always register the trap
trap "\rm -f '$FLAG_FILE'" EXIT

 if [[ ! -f "$FLAG_FILE" ]]; then
    fastfetch
    # Run Fastfetch
    
    print_logo(){    cat << "EOF"  
██████╗ ███████╗██╗   ██╗ ██████╗██████╗  █████╗ ███████╗████████╗
██╔══██╗██╔════╝██║   ██║██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
██║  ██║█████╗  ██║   ██║██║     ██████╔╝███████║█████╗     ██║   
██║  ██║██╔══╝  ╚██╗ ██╔╝██║     ██╔══██╗██╔══██║██╔══╝     ██║   
██████╔╝███████╗ ╚████╔╝ ╚██████╗██║  ██║██║  ██║██║        ██║   
╚═════╝ ╚══════╝  ╚═══╝   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝                                                                   
EOF
}
print_logo
#         figlet -f small  -w 120 "Shaharyar Shakir" | lolcat
  touch "$FLAG_FILE"  # Create the flag file to prevent re-running
fi
case $- in
    *i*) ;;
      *) return;;
esac
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Add in powerlevel10k theme
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# zsh installed Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# load zsh-completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# keybinds
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion style
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:completion:cd:*' fzf-preview  'ls --color $realpath'
zstyle ':fzf-tab:completion:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Add in snippets
zinit snippet OMZP::git
# zinit snippet OMZP::docker
zinit snippet OMZP::kubectl
 zinit snippet OMZP::command-not-found
zinit snippet OMZP::aws
zinit snippet OMZP::terraform
zinit snippet OMZP::kubectx
zinit snippet OMZP::npm
zinit snippet OMZP::node
zinit snippet OMZP::yarn
zinit snippet OMZP::nvm
zinit snippet OMZP::z
zinit snippet OMZP::aliases
zinit snippet OMZP::common-aliases
zinit snippet OMZP::extract
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::history
zinit snippet OMZP::sudo
zinit snippet OMZP::gcloud
zinit snippet OMZP::fzf
zinit snippet OMZP::themes
zinit snippet OMZP::python
zinit snippet OMZP::pip
zinit snippet OMZP::virtualenv
zinit snippet OMZP::rails
zinit snippet OMZP::composer
# Enable Devbox CLI autocomplete
if command -v devbox &> /dev/null; then
eval "$(devbox completion zsh)"
fi

# aliases
alias ls='ls --color'
alias vi='nvim'
alias c='clear'
alias v='nvim'
alias y='yazi'
alias lg='lazygit'

#vs codium
# alias codium='flatpak run com.vscodium.codium'

# alias for ls/eza
if command -v eza &> /dev/null; then
alias ls='eza --icons -lah --group-directories-first --git'
alias lss="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lt='eza -T --icons'
alias ll='eza -lh --icons'
alias la='eza -la --icons'
alias lsize='eza -lh --icons -s size -r'
alias lmod='eza -lh --icons -s modified'
alias lg='eza -lh --icons --git'
alias l='eza -l --icons --git'
alias cmatrix='cmatrix -u 10 -B -f'

else
alias la='ls -Alh'                # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -ltcrh'              # sort by change time
alias lu='ls -lturh'              # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='ls -Fls'                # long listing format
alias labc='ls -lap'              # alphabetical sort
alias lf="ls -l | egrep -v '^d'"  # files only
alias ldir="ls -l | egrep '^d'"   # directories only
alias lla='ls -Al'                # List and Hidden Files
alias las='ls -A'                 # Hidden Files
alias lls='ls -l'                 # List
fi

# Change directory aliases
alias he='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cls='clear'

# kubectl
alias k='kubectl'
alias kx='kubectl exec -it'
alias kg='kubectl get'

# github cli alias
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'
alias gh-issue='gh issue create --web'
alias gh-pr='gh pr create --web'

# shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
export _ZO_ECHO=1


# --- Automatically run ls after cd/z/zoxide in zsh ---
__last_dir="$PWD"

__auto_ls_on_cd() {
    if [[ "$PWD" != "$__last_dir" ]]; then
        __last_dir="$PWD"
        echo -e "\n📂 $(pwd)"
        ls --color=auto -lah
    fi
}

# Use zsh's built-in chpwd hook
autoload -Uz add-zsh-hook
add-zsh-hook chpwd __auto_ls_on_cd

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Check if ripgrep is installed
if command -v rg &> /dev/null; then
    # Alias grep to rg if ripgrep is installed
    alias grep='rg'
else
    # Alias grep to /usr/bin/grep with GREP_OPTIONS if ripgrep is not installed
    alias grep="/usr/bin/grep $GREP_OPTIONS"
fi
unset GREP_OPTIONS

# Function to create a directory and change into it
mkdirg() {
  mkdir -p "$1" && cd "$1"
}

# Set default editor to Neovim
export EDITOR=nvim
export VISUAL=nvim
export YAZI_EDITOR="nvim"
export TERM=xterm-256color

# Taskfile
alias t='task'
alias tl='task --list-all'

# lazygit
alias lg='lazygit'

# # To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zshexport

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


export PATH="$PATH:$HOME/.rvm/bin"
if command -v mise >/dev/null 2>&1; then

eval "$(~/.local/bin/mise activate zsh)"
fi
# Taskfile completion
if command -v task >/dev/null 2>&1; then
  eval "$(task --completion zsh)"
fi
# starship
export STARSHIP_CONFIG="$HOME/.config/starship_zsh.toml"
eval "$(starship init zsh)"

# Add Homebrew to PATH if installed
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
# Enable instant prompt for Powerlevel10k
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
export BUILDKIT_HOST=unix:///run/user/1000/buildkit/buildkitd.sock
export STARSHIP_CONFIG="/home/shaharyar/.config/starship_zsh.toml"
export PATH="$HOME/.local/bin:$PATH"
export SHELL=$(which zsh)

export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/home/shaharyar/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Load Angular CLI autocompletion.
if command -v node >/dev/null 2>&1; then
source <(ng completion script)
fi

# mise
if command -v mise >/dev/null 2>&1; then
eval "$(mise activate zsh)"
fi

# fnm
if command -v fnm >/dev/null 2>&1; then
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env)"
fi

# >>> conda initialize >>>
__conda_setup="$('/home/shaharyar/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/shaharyar/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/shaharyar/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/shaharyar/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
