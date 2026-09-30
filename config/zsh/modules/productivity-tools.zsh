#!/bin/zsh
# Productivity tools: zoxide, hstr, broot, direnv, mise

# Zoxide setup (https://github.com/ajeetdsouza/zoxide)
eval "$(zoxide init zsh)"
alias cd="z"

# hstr setup - improved history
export HSTR_CONFIG=hicolor,keywords,rawhistory
export HSTR_TIOCSTI=n
# Widget, not a `bindkey -s` macro: macros relying on emacs-mode keys break under vi mode
hstr_no_tiocsti() {
  zle -I
  { HSTR_OUT="$( { </dev/tty hstr -- ${BUFFER}; } 2>&1 1>&3 3>&- )"; } 3>&1;
  BUFFER="${HSTR_OUT}"
  CURSOR=${#BUFFER}
  zle redisplay
}
zle -N hstr_no_tiocsti
bindkey -M viins '^R' hstr_no_tiocsti

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
