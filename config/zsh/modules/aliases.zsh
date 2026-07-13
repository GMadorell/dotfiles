#!/bin/zsh
# Basic aliases and shortcuts

# NeoVim
alias n='nvim'

# HTTPie
alias get="http GET"
alias post="http POST"

# Sudo
alias please='sudo $(fc -ln -1)'
alias pls=please
alias suda=please

# Math/Calculator
alias math="amm --silent $PROJECTS_PATH/CLIMath/CLIMath.sc"
alias calc=math
alias calculate=math
alias m=math

# Time/Date
alias dateiso="date +%F"

# Editor
alias vscode="code"

# System monitoring
alias mntr="glances"
alias monitor="mntr"

# Build tools
alias maven="mvn"

# Directory shortcuts
alias cd.="cd ."
alias cd..="cd .."
alias cd...="cd ..."
alias cd....="cd ...."
alias cd.....="cd ....."
alias cd......="cd ......"
alias cd.......="cd ......."
alias cd........="cd ........"
alias .1="cd .."
alias .2="cd ..."
alias .3="cd ...."
alias .4="cd ....."
alias .5="cd ......"
alias .6="cd ......."
alias .7="cd ........"
alias cdp="cd $PROJECTS_PATH"
alias zp="cdp"
alias cddownloads="cd ~/downloads/"
alias cdd="cddownloads"
alias cdh="cd $HOME"

# Clipboard
alias copy="pbcopy"
alias paste="pbpaste"
alias cbcopy=copy
alias cbpaste=paste
alias kbcopy=copy
alias kbcp=copy
alias kbpaste=paste

# Screen
alias cl="printf \"\033c\""
alias clean="cl"

# History
function history_grep() {
  if [ $# -eq 1 ]; then
      history | grep $1
  else
      echo "$LOG_ERROR history_grep accepts a single parameter only (what to grep the history for)"
  fi
}
alias h="history"
alias hist="history"
alias hgrep="history_grep"
alias hg="history_grep"

# System ports
alias ports="sudo lsof -PiTCP -sTCP:LISTEN"

# ZSH config
alias sourcezshrc="source $HOME/.zshrc"
alias srczshrc=sourcezshrc
alias editzshrc="$EDITOR $HOME/.zshrc"

# Network
alias pingg="ping www.google.com"
