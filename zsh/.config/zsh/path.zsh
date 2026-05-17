# Tool-specific roots
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export EDITOR=nvim
export SUDO_EDITOR=nvim
export GOPATH="$HOME/.local/share/go"

# Tool-specific roots
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
export EDITOR=nvim
export SUDO_EDITOR=nvim

# Go Environment Cleanups (Set these before building the path array)
export GOPATH="$HOME/.local/share/go"
export GOCACHE="$HOME/.cache/go-build"

# Standard Paths
path=(
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.npm-global/bin"
    "$GOPATH/bin" # This dynamically points to your new hidden Go bin directory
    $path
)
export PATH
