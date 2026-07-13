#!/bin/zsh

export GOPATH="$HOME/golang_workspace"
export PATH="/usr/local/sbin:/usr/local/bin:bin:/usr/sbin:/sbin:$HOME/bin:/usr/bin:$GOPATH/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
if command -v brew &>/dev/null && command -v rustup &>/dev/null; then
  export PATH="$(brew --prefix rustup)/bin:$PATH"
fi
export DOTFILES_PATH="$HOME/.dotfiles"
export MANPATH="/usr/local/man:$MANPATH"
export PROJECTS_PATH="$HOME/projects"
