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

# Listing shortcuts (ls abstractions with eza)
alias lst="eza -l -h -a -a --time-style long-iso"
alias l=lst
alias lst_extended="eza -l -h -a -a --time-style long-iso --extended"
alias lste="lst_extended"
alias lst_date_created="eza -l -h -t created --sort created -a -a --time-style long-iso"
alias lst_created="lst_date_created"
alias lstcreated="lst_date_created"
alias lstc="lst_date_created"
alias lc="lst_date_created"
alias lst_date_modified="eza -l -h -t modified --sort modified -a -a --time-style long-iso"
alias lst_modified="lst_date_modified"
alias lstmodified="lst_date_modified"
alias lm="lst_date_modified"
alias lg="ls_grep"
alias lsg="ls_grep"
alias cdls="lscd"
alias lsto="lst_open"
alias lo="lst_open"
alias lstco="lstc_open"
alias lco="lstc_open"

# File browser
alias dir="ranger"

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

# JSON
alias compress_json="jq -c"
alias json_compress=compress_json

# Git (basic)
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpfn="git push --force-with-lease --no-verify"
alias gpumaster="git push upstream HEAD:master"
alias gpoh="git push origin HEAD"
alias gp_same_name="gpoh"
alias gp_skip_hooks="git push --no-verify"
alias gpskiphooks="git push --no-verify"
alias gp_no_hooks="git push --no-verify"
alias gpnohooks="git push --no-verify"
alias gpn="git push --no-verify"
alias gpt="git push --tags"
