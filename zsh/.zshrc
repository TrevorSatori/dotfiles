# --- ZSH Configuration Entry Point ---
export ZSH_CONFIG="$HOME/.config/zsh"

# Load modules
if [ -d "$ZSH_CONFIG" ]; then
    for file in "$ZSH_CONFIG"/*.zsh; do
        source "$file"
    done
fi

# Initializations
eval "$(starship init zsh)"
eval "$(pyenv init -)"

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Visuals
fastfetch
