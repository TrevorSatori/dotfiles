# SSH Agent
# This starts the agent if it's not running
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Basic Shell Behavior
setopt autocd extendedglob
unsetopt beep

# Vi Mode & Keybindings
bindkey -v
export KEYTIMEOUT=1

# Enable word navigation with Ctrl + Arrow keys
# (Note: Some terminal emulators might need different codes, 
# but these are standard for xterm/alacritty/foot)
bindkey '^[[1;5D' backward-word  # Ctrl + Left Arrow
bindkey '^[[1;5C' forward-word   # Ctrl + Right Arrow
