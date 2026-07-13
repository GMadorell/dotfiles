#!/bin/zsh
# Homebrew setup and environment variables
# Depends: 01-exports.zsh (for DOTFILES_PATH)

# Initialize Homebrew
# Try common brew locations: Apple Silicon first, then Intel/Homebrew on ARM, then system PATH
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

# Homebrew constants
export HOMEBREW_AUTO_UPDATE_SECS=25200
export HOMEBREW_NO_ANALYTICS=true
export HOMEBREW_INSTALL_BADGE="(ʘ‿ʘ)"
export HOMEBREW_BUNDLE_FILE_PATH=${DOTFILES_PATH}/Brewfile
