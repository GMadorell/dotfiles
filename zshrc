#!/bin/zsh
# Forward to modular zsh configuration
export ZSH_CONFIG="${ZDOTDIR:-$HOME/.config/zsh}"
source "$ZSH_CONFIG/init.zsh"
