#!/bin/zsh
# Homebrew setup and environment variables
# Depends: 01-exports.zsh (for DOTFILES_PATH)

# Initialize Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew constants
export HOMEBREW_AUTO_UPDATE_SECS=25200
export HOMEBREW_NO_ANALYTICS=true
export HOMEBREW_INSTALL_BADGE="(ʘ‿ʘ)"
export HOMEBREW_BUNDLE_FILE_PATH=${DOTFILES_PATH}/Brewfile
