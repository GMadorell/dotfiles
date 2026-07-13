#!/bin/zsh

# Set ZSH_CONFIG early
# Use ZSH_CONFIG if already set, otherwise derive from script location, ZDOTDIR, fallback to ~/.config/zsh
if [[ -z "$ZSH_CONFIG" ]]; then
  # Get the directory of this script
  local script_dir="${${(%):-%x}:h}"
  if [[ -d "$script_dir" && -f "$script_dir/init.zsh" ]]; then
    export ZSH_CONFIG="$script_dir"
  elif [[ -n "$ZDOTDIR" ]]; then
    export ZSH_CONFIG="$ZDOTDIR"
  else
    export ZSH_CONFIG="$HOME/.config/zsh"
  fi
fi

# Minimal oh-my-zsh setup (ZSH_THEME, plugins, HIST settings)
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_THEME="robbyrussell"
export ZSH_DISABLE_COMPFIX=true
plugins=(git)

# Load secrets if available
[ -f ~/.secrets ] && source ~/.secrets

# Source oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Source all conf.d files (01-09) in order
for conf in "$ZSH_CONFIG"/conf.d/*.zsh; do
  [ -f "$conf" ] && source "$conf"
done

# Source all module files in strict order
# 1. language-modes (for MODE flags)
[ -f "$ZSH_CONFIG"/modules/language-modes.zsh ] && source "$ZSH_CONFIG"/modules/language-modes.zsh

# 2. aliases
[ -f "$ZSH_CONFIG"/modules/aliases.zsh ] && source "$ZSH_CONFIG"/modules/aliases.zsh

# 3. git
[ -f "$ZSH_CONFIG"/modules/git.zsh ] && source "$ZSH_CONFIG"/modules/git.zsh

# 4. precmd-hooks
[ -f "$ZSH_CONFIG"/modules/precmd-hooks.zsh ] && source "$ZSH_CONFIG"/modules/precmd-hooks.zsh

# 5. productivity-tools
[ -f "$ZSH_CONFIG"/modules/productivity-tools.zsh ] && source "$ZSH_CONFIG"/modules/productivity-tools.zsh

# 6. languages
for lang in "$ZSH_CONFIG"/modules/languages/*.zsh; do
  [ -f "$lang" ] && source "$lang"
done

# 7. utils
for util in "$ZSH_CONFIG"/modules/utils/*.zsh; do
  [ -f "$util" ] && source "$util"
done

# 8. services (optional, can be commented out)
for service in "$ZSH_CONFIG"/modules/services/*.zsh; do
  [ -f "$service" ] && source "$service"
done

# 9. shell-final LAST
[ -f "$ZSH_CONFIG"/modules/shell-final.zsh ] && source "$ZSH_CONFIG"/modules/shell-final.zsh
