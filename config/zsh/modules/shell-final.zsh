#!/bin/zsh
# Final setup: sdkman, bun, hushlogin
# Must be sourced LAST in init.zsh

# Disable login message
touch ~/.hushlogin

# sdkman - Software Development Kit Manager
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun - JavaScript runtime
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# starship prompt - must init after oh-my-zsh so nothing clobbers PROMPT
command -v starship &>/dev/null && eval "$(starship init zsh)"
