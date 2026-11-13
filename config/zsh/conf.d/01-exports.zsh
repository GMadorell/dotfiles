#!/bin/zsh

export GOPATH="$HOME/golang_workspace"
export PATH="/usr/local/sbin:/usr/local/bin:bin:/usr/sbin:/sbin:$HOME/bin:/usr/bin:$GOPATH/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# Unity installer owns this file (adds ~/.unity/bin to PATH); source it so upgrades stay in sync.
[ -f "$HOME/.unity/env" ] && . "$HOME/.unity/env"
if command -v brew &>/dev/null && command -v rustup &>/dev/null; then
  export PATH="$(brew --prefix rustup)/bin:$PATH"
fi
# .NET global tools' apphost looks for the runtime in /usr/local/share/dotnet, not Homebrew's keg.
if [ -d /opt/homebrew/opt/dotnet/libexec ]; then
  export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
  export PATH="$PATH:$HOME/.dotnet/tools"
fi
export DOTFILES_PATH="$HOME/.dotfiles"
export MANPATH="/usr/local/man:$MANPATH"
export PROJECTS_PATH="$HOME/projects"
