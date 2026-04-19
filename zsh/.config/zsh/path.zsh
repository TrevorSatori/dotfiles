# Standard Paths
path=(
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.npm-global/bin"
    "$HOME/go/bin"
    $path
)
export PATH

# Tool-specific roots
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export EDITOR=nvim
export SUDO_EDITOR=nvim
