# Zsh Vi Mode
bindkey -v

# Zsh Autocomplete Settings
autoload -Uz compinit; compinit
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
autoload -U +X bashcompinit && bashcompinit

# Zsh Prompt Configuration
FIRST_RUN=true
precmd() {
  if ! $FIRST_RUN; then
    print ""
  fi
  FIRST_RUN=false
}
preexec() { print "" }
NEWLINE=$'\n'
PROMPT="%F{yellow}%~%f${NEWLINE}→ "

# Zsh-Specific History Management
export HISTFILE=~/.histfile
export SAVEHIST=1000000    
setopt HIST_IGNORE_ALL_DUPS  
setopt HIST_SAVE_NO_DUPS  
setopt HIST_REDUCE_BLANKS  
setopt INC_APPEND_HISTORY_TIME  
setopt EXTENDED_HISTORY  

# Custom Zsh Keybindings
bindkey -s "^[\\" "~/.config/personal_scripts/tmux-session.sh\n"

# Load the shared configuration
if [ -f "$HOME/.shell_common_rc" ]; then
    source "$HOME/.shell_common_rc"
fi

