#!/bin/zsh
# Final setup: sdkman, bun, hushlogin
# Must be sourced LAST in init.zsh

# Disable login message
touch ~/.hushlogin

# sdkman - Software Development Kit Manager
export SDKMAN_DIR="/Users/gerard/.sdkman"
[[ -s "/Users/gerard/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/gerard/.sdkman/bin/sdkman-init.sh"

# bun - JavaScript runtime
[ -s "/Users/gerard/.bun/_bun" ] && source "/Users/gerard/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
