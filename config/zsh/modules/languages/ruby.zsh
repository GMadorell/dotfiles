#!/bin/zsh
# Ruby setup (rbenv)
# Depends: modules/language-modes.zsh (for RUBY_MODE flag)

function setup_ruby() {
  eval "$(rbenv init -)"
}

alias toggle_ruby="setup_ruby"
alias enable_ruby="setup_ruby"
alias ruby_enable=enable_ruby
alias activate_ruby="setup_ruby"

if (($RUBY_MODE)) ; then
  setup_ruby
fi
