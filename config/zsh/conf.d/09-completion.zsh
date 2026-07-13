#!/bin/zsh
# Completion setup and configuration
# Note: Must be sourced AFTER oh-my-zsh.sh (sourced in init.zsh)

# Add zsh functions directory to fpath
fpath+=~/.zfunc

# Initialize completions
autoload -Uz compinit && compinit

# Completion styling
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''

# Bracketed paste hotfix (for slow paste of huge texts)
# See: https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
