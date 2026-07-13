#!/bin/zsh
# Keybindings and keyboard configuration

# Core keybindings
bindkey ^A beginning-of-line         # Ctrl+A for moving to beggining
bindkey ^S backward-word             # Ctrl+S for moving a word backward
bindkey ^D forward-word              # Ctrl+D for moving a word forward
bindkey ^F end-of-line               # Ctrl+F for moving till the end
bindkey ^W backward-delete-word      # Ctrl+W to delete a word backward
bindkey ^E kill-word                 # Ctrl+E to delete a word forward

# Edit command line with ESC (vi-like editing)
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\033' edit-command-line

# Key timeout for escape sequences (in milliseconds)
KEYTIMEOUT=1

# Autosuggest styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
