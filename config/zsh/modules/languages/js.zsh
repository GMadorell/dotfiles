#!/bin/zsh
# JavaScript setup (NVM)
# Depends: modules/language-modes.zsh (for JS_MODE flag)

function setup_js() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

alias toggle_js="setup_js"
alias enable_js="setup_js"
alias js_enable=enable_js

if (($JS_MODE)) ; then
  setup_js
fi
