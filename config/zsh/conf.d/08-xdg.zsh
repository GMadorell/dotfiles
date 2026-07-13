#!/bin/zsh
# XDG Base Directory paths for zsh-specific caches and state
# Depends: 01-exports.zsh

# Completion cache in XDG cache directory
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# Zoxide state in XDG state directory
export _ZO_DATA_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
mkdir -p "$_ZO_DATA_DIR"
