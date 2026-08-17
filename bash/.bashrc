# Android Bash Prompt (Simple and clean)
export PS1="\[\033[33m\]\w\[\033[0m\]\n→ "

# Bash History adjustments
export HISTFILESIZE=1000000
shopt -s histappend # Append to history instead of overwriting

# FZF
export FZF_CTRL_R_OPTS="--height 95%"
eval "$(fzf --bash)"

# Load the shared configuration
if [ -f "$HOME/.shell_common" ]; then
    . "$HOME/.shell_common"
fi

