#!/bin/zsh
# Precmd hooks for shell prompt and title management

export DISABLE_AUTO_TITLE="true"

# Set window title to collapsed pwd
set_window_title_to_collapsed_pwd() {
  local _collapsed_pwd=$(pwd | perl -pe "s|^$HOME|~|g; s|/([^/])[^/]*(?=/[^/]*/)|/\$1|g")
  window_title="\e]0;${_collapsed_pwd}\a"
  echo -ne "$window_title"
}
precmd_functions+=(set_window_title_to_collapsed_pwd)

# Add function to evaluate bash's PROMPT_COMMAND variable
prmptcmd() { eval "$PROMPT_COMMAND" }
precmd_functions+=(prmptcmd)
