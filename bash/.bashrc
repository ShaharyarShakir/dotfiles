# ~/.bashrc - Main shell config, sources additional modular files
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}# # Run fastfetch only once per login session
#set -x  # shows each command as it runs (for bash)
# ble.sh
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



####################################################################
####################### Aliases ####################################
#####################################################################
# Aliases for common commands
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

# fastfetch
alias ff='fastfetch'

# IntelliJ-IDEA-Community
alias idea="flatpak run com.jetbrains.IntelliJ-IDEA-Community"

# nixos alias
alias nrs='sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos'

# alias for exit
alias :xa='exit'

# github cli 
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'
alias gh-createp='gh repo create --public --source=. --remote=origin && git push -u --all && gh browse'

#vs codium
alias codium='flatpak run com.vscodium.codium'

# git
alias ga='git add .'
alias gc='git commit -m'
alias gac='git add . && git commit -m "Updated: $(git diff --name-only --cached | tr "\n" " ")"'
alias gs='git status'
alias glog="git log --oneline --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gp='git push'
alias gP='git pull'
alias lg='lazygit'
alias gu='gitui'
alias gb='git branch'

# fzf 
alias fh='history | fzf'
alias fo='find . -type f | fzf'
alias vf='nvim $(fzf --preview "bat --color=always {}")'


# devpod
alias dp='devpod'
alias dss='devpod ssh'
alias dl='devpod ls'
alias dd='devpod delete'

# kubectl / minikube
alias k='kubectl'
alias mk='minikube'

# kubectx / kubens
alias kx='kubectx'
alias kn='kubens'

# Taskfile
alias t='task'
alias tl='task --list-all'

# bash
alias vb='nvim ~/.bashrc'
alias sb='source ~/.bashrc'
alias cb='cd /d/BSCS/git-repos'

# trash-cli
if command -v trash-put &>/dev/null
then
alias rm='trash-put'
else
alias rm='rm -i'
fi

# project manager
bind -x '"\C-p":"~/dotfiles/scripts/tmux-project.sh"'

# Vim / Neovim
if command -v nvim &> /dev/null; then
alias vim='nvim'
alias v='nvim'
alias v.='nvim .'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'
else
export EDITOR=vim
export VISUAL=vim
fi

# yazi / tmux / kill
alias y="yazi"
alias tm='tmux'
alias tmn='tmux new -s '
alias tml='tmux ls'
alias tma='tmux attach -t '
alias zj='zellij'

# aliases to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias less='less -R'
alias cls='clear'
alias c='clear'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'

# posting - an http client to view data can also use httpie, curlie, kulala.nvim
alias pos='posting'

# Change directory aliases
alias he='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

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

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# aliases to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Zoxide (better cd) 
# alias cd="z "
export _ZO_ECHO=1
# alias for oldfiles
alias nlof='list_oldfiles'

# alias to cleanup unused docker containers, images, networks, and volumes
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

# pnpm node package manager
alias pn="pnpm"
alias pnx="pnpm dlx"

# neoVim Starter
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=kickstart nvim"
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
alias nvim-astro="NVIM_APPNAME=neobean nvim"



################################################################
################## END #########################################
################################################################

#################################################################
################## Functions ####################################
#################################################################

#################################################################
########## Export ssh agent to dev containers ###################
#################################################################
# Location to store the ssh-agent environment file
SSH_ENV="$HOME/.ssh/ssh-agent"

# Function to start the ssh-agent and save its environment
start_agent() {
    echo "Starting new ssh-agent..."
    ssh-agent -s > "$SSH_ENV"
    chmod 600 "$SSH_ENV"
    source "$SSH_ENV"
}


# Only run if SSH agent socket is not set or invalid
if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l &>/dev/null; then
    if [ -f "$SSH_ENV" ]; then
        source "$SSH_ENV"
        # If the agent PID is dead or unusable, start a new one
        if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || ! ssh-add -l &>/dev/null; then
            echo "Removing stale SSH agent file and starting new agent..."
            rm -f "$SSH_ENV"
            start_agent
        fi
    else
        start_agent
    fi
fi

# Auto-add id_ed25519 if agent has no identities
if ! ssh-add -l | grep -q "id_ed25519"; then
    ssh-add ~/.ssh/id_ed25519 &>/dev/null
fi

# This is important for VS Code and Dev Containers
export SSH_AGENT_SOCK=$SSH_AUTH_SOCK
#################################################################
####################  END   #####################################
#################################################################


# Function that uses fzf to choose a devbox command
devbox_menu() {
    local options=(
        "devbox init"
        "devbox add"
        "devbox shell"
    )

    local selected
    selected=$(printf "%s\n" "${options[@]}" | fzf --prompt="Devbox > " --height=10 --border)

    case "$selected" in
        "devbox init")
            echo "Running: devbox init"
            devbox init
            ;;
        "devbox add")
            read -rp "Enter package name to add: " pkg
            echo "Running: devbox add $pkg"
            devbox add "$pkg"
            ;;
        "devbox shell")
            echo "Running: devbox shell"
            devbox shell
            ;;
        *)
            echo "Cancelled or invalid selection."
            ;;
    esac
}

bind -x '"\C-g": devbox_menu'



# Function to open Neovim with different configurations using fzf
function nvims() {
  items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim" "neobean")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)

  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    NVIM_APPNAME="" nvim "$@"
  else
    NVIM_APPNAME="$config" nvim "$@"
  fi
}
   bind -x '"\C-n": nvims'


# Script to list recent files and open nvim using fzf
list_oldfiles() {
    # Get the oldfiles list from Neovim
    local oldfiles
    IFS=$'\n' read -r -d '' -a oldfiles < <(nvim -u NONE --headless +'lua io.write(table.concat(vim.v.oldfiles, "\n"))' +qa && printf '\0')

    # Filter invalid paths or files not found
    local valid_files=()
    for file in "${oldfiles[@]}"; do
        if [[ -f "$file" ]]; then
            valid_files+=("$file")
        fi
    done

    # Use fzf to select from valid files
    local files
    files=$(printf "%s\n" "${valid_files[@]}" | \
        grep -v '\[.*' | \
        fzf --multi \
            --preview 'bat -n --color=always --line-range=:500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Error previewing file"' \
            --height=70% \
            --layout=default)

    # If files are selected, open them in Neovim
    if [[ -n "$files" ]]; then
        nvim $(echo "$files")
    fi
}

# binding the function to ctrl l
bind -x '"\C-o": list_oldfiles'

# Function to extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2|*.tbz2)   tar xjf "$1" ;;
            *.tar.gz|*.tgz)    tar xzf "$1" ;;
            *.tar.xz|*.txz)    tar xJf "$1" ;;
            *.tar.lzma)        tar --lzma -xf "$1" ;;
            *.tar)             tar xf "$1" ;;
            *.bz2)             bunzip2 "$1" ;;
            *.gz)              gunzip "$1" ;;
            *.xz)              unxz "$1" ;;
            *.lzma)            unlzma "$1" ;;
            *.zip)             unzip "$1" ;;
            *.7z)              7z x "$1" ;;
            *.rar)             unrar x "$1" ;;
            *.Z)               uncompress "$1" ;;
            *.deb)             ar x "$1" ;;
            *.rpm)             rpm2cpio "$1" | cpio -idmv ;;
            *.iso)             7z x "$1" ;;  # needs p7zip
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo " '$1' is not a valid file"
    fi
}

distribution () {
    local dtype="unknown"  # Default to unknown

    # Use /etc/os-release for modern distro identification
    if [ -r /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            fedora|rhel|centos)
                dtype="redhat"
                ;;
            sles|opensuse*)
                dtype="suse"
                ;;
           	nixos)
	     dtype="nixos"	
	         ;;
            ubuntu|debian)
                dtype="debian"
                ;;
            gentoo)
                dtype="gentoo"
                ;;
            arch|manjaro)
                dtype="arch"
                ;;
            slackware)
                dtype="slackware"
                ;;
            *)
                # Check ID_LIKE only if dtype is still unknown
                if [ -n "$ID_LIKE" ]; then
                    case $ID_LIKE in
                        *fedora*|*rhel*|*centos*)
                            dtype="redhat"
                            ;;
                        *sles*|*opensuse*)
                            dtype="suse"
                            ;;
                        *ubuntu*|*debian*)
                            dtype="debian"
                            ;;
                        *gentoo*)
                            dtype="gentoo"
                            ;;
                        *arch*)
                            dtype="arch"
                            ;;
                        *slackware*)
                            dtype="slackware"
                            ;;
                    esac
                fi

                # If ID or ID_LIKE is not recognized, keep dtype as unknown
                ;;
        esac
    fi

    echo $dtype
}

# bat/cat alias
DISTRIBUTION=$(distribution)
if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
    if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ] || [ "$DISTRIBUTION" == "nixos" ]; then
        alias cat='bat'
    else
        alias cat='batcat'
    fi
fi

# Show the current version of the operating system
ver() {
    local dtype
    dtype=$(distribution)

    case $dtype in
        "redhat")
            if [ -s /etc/redhat-release ]; then
                cat /etc/redhat-release
            else
                cat /etc/issue
            fi
            uname -a
            ;;
        "suse")
            cat /etc/SuSE-release
            ;;
        "debian")
            lsb_release -a
            ;;
        "gentoo")
            cat /etc/gentoo-release
            ;;
        "arch")
            cat /etc/os-release
            ;;
        "slackware")
            cat /etc/slackware-version
            ;;
        *)
            if [ -s /etc/issue ]; then
                cat /etc/issue
            else
                echo "Error: Unknown distribution"
                exit 1
            fi
            ;;
    esac
}

# Automatically install the needed support files for this .bashrc file
install_bashrc_support() {
	local dtype
	dtype=$(distribution)

	case $dtype in
		"redhat")
			sudo yum install multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		"suse")
			sudo zypper install multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		"debian")
			sudo apt-get install multitail tree zoxide trash-cli fzf bash-completion
			# Fetch the latest fastfetch release URL for linux-amd64 deb file
			FASTFETCH_URL=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep "browser_download_url.*linux-amd64.deb" | cut -d '"' -f 4)

			# Download the latest fastfetch deb file
			curl -sL $FASTFETCH_URL -o /tmp/fastfetch_latest_amd64.deb

			# Install the downloaded deb file using apt-get
			sudo apt-get install /tmp/fastfetch_latest_amd64.deb
			;;
		"arch")
			sudo paru multitail tree zoxide trash-cli fzf bash-completion fastfetch
			;;
		"slackware")
			echo "No install support for Slackware"
			;;
		*)
			echo "Unknown distribution"
			;;
	esac
}


# Enable history settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Window size check
shopt -s checkwinsize

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    /etc/bash_completion.d/000_bash_completion_compat.bash
fi
fi

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Automatically do an ls after each cd, z, or zoxide
__last_dir="$PWD"

__auto_ls_on_cd() {
    if [[ "$PWD" != "$__last_dir" ]]; then
        __last_dir="$PWD"
       # echo -e "\n📂 $(pwd)"
        ls --color=auto -lah
    fi
}

# GitHub Titus Additions

gcom() {
	git add .
	git commit -m "$1"
}
lazyg() {
	git add .
	git commit -m "$1"
	git push
}

# using fzf to search history in atuin
atuin_fzf_history() {
  local selected_command
  selected_command=$( $history list --cmd-only | fzf --height 40% --reverse --info inline)
  if [ -n "$selected_command" ]; then
    READLINE_LINE="$selected_command"
    READLINE_POINT=${#READLINE_LINE}
  fi
}

bind -x '"\C-r": atuin_fzf_history'


################################################################################
###################### END #####################################################
################################################################################

#################################################################################
###################### Environment Variables ####################################
#################################################################################

# Set default editor to Neovim
export EDITOR=nvim
export VISUAL=nvim
export YAZI_EDITOR="nvim"
:
# Set language and encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Path modifications (ensure binaries are found)
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Use bat as default pager (if installed)
export BAT_THEME="tokyonight_night"
export MANPAGER="sh -c 'col -bx | bat --paging=always -l man'"

# for atuin commadline history
  export ATUIN_NOBIND=true

# fzf integration (if installed)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}
# --- setup fzf theme ---
#fg="#CBE0F0"
#bg="#011628"
#bg_highlight="#143652"
#purple="#B388FF"
#blue="#06BCE4"
#cyan="#2CF9ED"

#export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# --- Setup fzf previews ----
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"


#################################################################################
############################# END ###############################################
#################################################################################


# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}
   bind -x '"\C-f": _fzf_comprun'




###################################################################################
################### Set the ultimate amazing command prompt #######################
###################################################################################

alias hug="hugo server -F --bind=10.0.0.97 --baseURL=http://10.0.0.97"

zoxide-fzf() {
  local dir
  dir=$(zoxide query -l | fzf) && cd "$dir"
}

# Use a keyboard shortcut (Ctrl+f) to call zoxide-fzf
bind -x '"\C-f":zoxide-fzf'
export TERM=xterm-256color

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export MPD_HOST=~/.config/mpd/socket
export MAVEN_OPTS="--enable-native-access=ALL-UNNAMED"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER="less -R --use-color -Dd+r -Du+b"

# pnpm
export PNPM_HOME="/home/shaharyar/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

################################################################################
#############################  END  ############################################
################################################################################

#################################################################################
######################### SHELL Commands and Configurations #####################
#################################################################################

# added homebrew config for macos
if command -v brew &> /dev/null; then
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Enable fancy prompt using starship
export STARSHIP_CONFIG="$HOME/.config/starship_bash.toml"
eval "$(starship init bash)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"

#Zoxide (better cd)
eval "$(zoxide init --cmd cd bash)"


# Hook it into PROMPT_COMMAND without overwriting it
if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="__auto_ls_on_cd"
else
    PROMPT_COMMAND="__auto_ls_on_cd; $PROMPT_COMMAND"
fi
# Taskfile completion for task command
if command -v task >/dev/null; then
eval "$(task --completion bash)"
fi

# Devbox global shell environment
eval "$(devbox global shellenv)"

# buildkit configuration
export BUILDKIT_HOST=unix:///run/user/1000/buildkit/buildkitd.sock
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
#################################################################################
########################### END OF .bashrc ######################################
#################################################################################
export STARSHIP_CONFIG="/home/shaharyar/.config/starship_bash.toml"
export PATH="$HOME/.local/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/home/shaharyar/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)


export STARSHIP_CONFIG="/home/shaharyar/.config/starship_bash.toml"
export STARSHIP_CONFIG="/home/shaharyar/.config/starship_bash.toml"
export STARSHIP_CONFIG="/home/shaharyar/.config/starship_bash.toml"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
