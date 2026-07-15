#!/bin/zsh

# ZSH_CONFIG must be set by the caller (the root zshrc sets it before
# sourcing this file). Fail fast instead of guessing — a missing/wrong
# ZSH_CONFIG is a config error, not something to silently paper over.
if [[ -z "$ZSH_CONFIG" ]]; then
  echo "init.zsh: \$ZSH_CONFIG is not set, refusing to load. Set it to this file's directory before sourcing (the root zshrc does this)." >&2
  return 1
fi

# Minimal oh-my-zsh setup (ZSH_THEME, plugins, HIST settings)
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_THEME=""
export ZSH_DISABLE_COMPFIX=true
export DISABLE_MAGIC_FUNCTIONS=true
plugins=(zsh-autosuggestions zsh-syntax-highlighting)

# Load secrets if available
[ -f ~/.secrets ] && source ~/.secrets

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Load conf.d (core settings, in numeric order)
[ -f "$ZSH_CONFIG"/conf.d/01-exports.zsh ] && source "$ZSH_CONFIG"/conf.d/01-exports.zsh
[ -f "$ZSH_CONFIG"/conf.d/02-brew.zsh ] && source "$ZSH_CONFIG"/conf.d/02-brew.zsh
[ -f "$ZSH_CONFIG"/conf.d/03-logging.zsh ] && source "$ZSH_CONFIG"/conf.d/03-logging.zsh
[ -f "$ZSH_CONFIG"/conf.d/04-localization.zsh ] && source "$ZSH_CONFIG"/conf.d/04-localization.zsh
[ -f "$ZSH_CONFIG"/conf.d/05-editor.zsh ] && source "$ZSH_CONFIG"/conf.d/05-editor.zsh
[ -f "$ZSH_CONFIG"/conf.d/06-keybindings.zsh ] && source "$ZSH_CONFIG"/conf.d/06-keybindings.zsh
[ -f "$ZSH_CONFIG"/conf.d/07-shell-options.zsh ] && source "$ZSH_CONFIG"/conf.d/07-shell-options.zsh
[ -f "$ZSH_CONFIG"/conf.d/08-xdg.zsh ] && source "$ZSH_CONFIG"/conf.d/08-xdg.zsh
[ -f "$ZSH_CONFIG"/conf.d/09-completion.zsh ] && source "$ZSH_CONFIG"/conf.d/09-completion.zsh

# Load modules (features)
[ -f "$ZSH_CONFIG"/modules/language-modes.zsh ] && source "$ZSH_CONFIG"/modules/language-modes.zsh
[ -f "$ZSH_CONFIG"/modules/aliases.zsh ] && source "$ZSH_CONFIG"/modules/aliases.zsh
[ -f "$ZSH_CONFIG"/modules/git.zsh ] && source "$ZSH_CONFIG"/modules/git.zsh
[ -f "$ZSH_CONFIG"/modules/precmd-hooks.zsh ] && source "$ZSH_CONFIG"/modules/precmd-hooks.zsh
[ -f "$ZSH_CONFIG"/modules/productivity-tools.zsh ] && source "$ZSH_CONFIG"/modules/productivity-tools.zsh

# Load language-specific setups (conditional initialization)
[ -f "$ZSH_CONFIG"/modules/languages/python.zsh ] && source "$ZSH_CONFIG"/modules/languages/python.zsh
[ -f "$ZSH_CONFIG"/modules/languages/ruby.zsh ] && source "$ZSH_CONFIG"/modules/languages/ruby.zsh
[ -f "$ZSH_CONFIG"/modules/languages/php.zsh ] && source "$ZSH_CONFIG"/modules/languages/php.zsh
[ -f "$ZSH_CONFIG"/modules/languages/js.zsh ] && source "$ZSH_CONFIG"/modules/languages/js.zsh
[ -f "$ZSH_CONFIG"/modules/languages/rust.zsh ] && source "$ZSH_CONFIG"/modules/languages/rust.zsh

# Load utilities
[ -f "$ZSH_CONFIG"/modules/utils/string.zsh ] && source "$ZSH_CONFIG"/modules/utils/string.zsh
[ -f "$ZSH_CONFIG"/modules/utils/uuid.zsh ] && source "$ZSH_CONFIG"/modules/utils/uuid.zsh
[ -f "$ZSH_CONFIG"/modules/utils/files.zsh ] && source "$ZSH_CONFIG"/modules/utils/files.zsh
[ -f "$ZSH_CONFIG"/modules/utils/hardware.zsh ] && source "$ZSH_CONFIG"/modules/utils/hardware.zsh
[ -f "$ZSH_CONFIG"/modules/utils/shell.zsh ] && source "$ZSH_CONFIG"/modules/utils/shell.zsh
[ -f "$ZSH_CONFIG"/modules/utils/network.zsh ] && source "$ZSH_CONFIG"/modules/utils/network.zsh
[ -f "$ZSH_CONFIG"/modules/utils/weather.zsh ] && source "$ZSH_CONFIG"/modules/utils/weather.zsh
[ -f "$ZSH_CONFIG"/modules/utils/formatting.zsh ] && source "$ZSH_CONFIG"/modules/utils/formatting.zsh
[ -f "$ZSH_CONFIG"/modules/utils/time.zsh ] && source "$ZSH_CONFIG"/modules/utils/time.zsh

# Load service modules (optional, can be commented out)
[ -f "$ZSH_CONFIG"/modules/services/databases.zsh ] && source "$ZSH_CONFIG"/modules/services/databases.zsh
[ -f "$ZSH_CONFIG"/modules/services/messaging.zsh ] && source "$ZSH_CONFIG"/modules/services/messaging.zsh
[ -f "$ZSH_CONFIG"/modules/services/docker.zsh ] && source "$ZSH_CONFIG"/modules/services/docker.zsh
[ -f "$ZSH_CONFIG"/modules/services/datastores.zsh ] && source "$ZSH_CONFIG"/modules/services/datastores.zsh
[ -f "$ZSH_CONFIG"/modules/services/vpn.zsh ] && source "$ZSH_CONFIG"/modules/services/vpn.zsh
[ -f "$ZSH_CONFIG"/modules/services/cloud.zsh ] && source "$ZSH_CONFIG"/modules/services/cloud.zsh
[ -f "$ZSH_CONFIG"/modules/services/tools.zsh ] && source "$ZSH_CONFIG"/modules/services/tools.zsh

# Must be last
[ -f "$ZSH_CONFIG"/modules/shell-final.zsh ] && source "$ZSH_CONFIG"/modules/shell-final.zsh
