# The following lines were originally added by compinstall
# Updated to use $HOME for flexibility
zstyle :compinstall filename "$HOME/.zshrc"

# Command Completion Initialization
autoload -Uz compinit
compinit

# Case-insensitive completion (so 'cd downloads' finds 'Downloads')
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
