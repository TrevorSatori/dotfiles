# SSH Agent
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# Basic Shell Behavior
setopt autocd extendedglob
unsetopt beep

# Vi Mode & Keybindings
bindkey -v
export KEYTIMEOUT=1

# Default Editor
export EDITOR=nvim

# Enable word navigation with Ctrl + Arrow keys
# (Note: Some terminal emulators might need different codes, 
# but these are standard for xterm/alacritty/foot)
bindkey '^[[1;5D' backward-word  # Ctrl + Left Arrow
bindkey '^[[1;5C' forward-word   # Ctrl + Right Arrow

# Change cursor shape based on Vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    echo -ne '\e[1 q' # Block cursor for Normal Mode
  else
    echo -ne '\e[5 q' # Beam cursor for Insert Mode
  fi
}
zle -N zle-keymap-select

# Reset cursor to beam on every new prompt
precmd() {
  echo -ne '\e[5 q'
}

# The "jk" escape (optional but highly recommended for Neovim users)
bindkey -M viins 'jk' vi-cmd-mode
