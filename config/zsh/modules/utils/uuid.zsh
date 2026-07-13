#!/bin/zsh
# UUID generation

function randomuuid() {
  echo $(uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]')
}

function uuidcp() {
  randomuuid | tr -d '\n' | pbcopy && pbpaste && echo
}
