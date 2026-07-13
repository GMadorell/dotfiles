#!/bin/zsh
# Python setup (pyenv)
# Depends: modules/language-modes.zsh (for PYTHON_MODE flag)

function setup_python() {
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi
}

alias toggle_python="setup_python"
alias enable_python="setup_python"
alias python_enable=enable_python
alias activate_python="setup_python"

if (($PYTHON_MODE)) ; then
  setup_python
fi
