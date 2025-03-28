# ~/.bashrc - Main shell config, sources additional modular files
if command -v fastfetch &> /dev/null; then
    # Only run fastfetch if we're in an interactive shell
    if [[ $- == *i* ]]; then
        fastfetch
    fi
fi

# If not running interactively, exit
case $- in
    *i*) ;;
      *) return;;
esac

# Load all additional modular configurations
for file in ~/.config/bash/{aliases,exports,functions,prompt,completion,starship}; do
    [ -r "$file" ] && source "$file"
done

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
    . /etc/bash_completion
  fi  # <-- Corrected closing of if statement
fi  

