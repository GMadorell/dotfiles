#!/bin/zsh
# Productivity tools: zoxide, hstr, broot, direnv, mise

# Zoxide setup (https://github.com/ajeetdsouza/zoxide)
eval "$(zoxide init zsh)"
alias cd="z"

# hstr setup - improved history
export HH_CONFIG=hicolor,keywords,rawhistory
bindkey -s "\C-r" "\eqhh\n"

# broot function (file tree browser)
# This function starts broot and executes the command it produces
function br {
  local cmd cmd_file code
  cmd_file=$(mktemp)
  if broot --outcmd "$cmd_file" "$@"; then
    cmd=$(<"$cmd_file")
    command rm -f "$cmd_file"
    eval "$cmd"
  else
    code=$?
    command rm -f "$cmd_file"
    return "$code"
  fi
}

# Direnv - environment variables switcher
eval "$(direnv hook zsh)"

# Mise - tool manager for runtime versions
eval "$(mise activate zsh)"
