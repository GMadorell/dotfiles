#!/bin/zsh
# Formatting, time/date utilities and aliases

# JSON related
alias compress_json="jq -c"
alias json_compress=compress_json

# Case conversion
function title2kebab() { case_converter -f title -t kebab $1; };
function kebab2title() { case_converter -f kebab -t title $1; };

# Hardware related
## Battery status
function mouse_battery_percentage() {
  echo $(ioreg -n AppleDeviceManagementHIDEventService | grep -i batterypercent | sed 's/[^[:digit:]]//g')
}

alias copy="pbcopy"
alias paste="pbpaste"
alias cbcopy=copy
alias cbpaste=paste
alias kbcopy=copy
alias kbcp=copy
alias kbpaste=paste

# lst is the default to list files, abstracting away the used tool
# the --extended flag checks the extended extensions on files, useful to see if they are quarantined in MacOS, for example.
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
function ls_grep() {
    if [ $# -eq 1 ]; then
        lst | grep --ignore-case $1
    else
        echo "$LOG_ERROR ls_grep accepts a single parameter only (what to grep the ls result for)"
    fi
}
alias lg="ls_grep"
alias lsg="ls_grep"
function lscd() {
  local chosen_directory=$(ls -lt -d */ | awk '{print substr($0, index($0,$NF))}' |  percol --prompt='<green>Select directory to cd into:</green> %q')
  cd "$chosen_directory"
}
alias cdls="lscd"

function lst_open() {
  local chosen_lst_row=$(lst  | percol --prompt='<green>Select file to open:</green> %q')
  local chosen_file=$(echo $chosen_lst_row | awk '{print $NF}')
  $EDITOR $chosen_file
}
alias lsto="lst_open"
alias lo="lst_open"

function lstc_open() {
  local chosen_lst_row=$(lstc  | percol --prompt='<green>Select file to open:</green> %q')
  local chosen_file=$(echo $chosen_lst_row | awk '{print $NF}')
  $EDITOR $chosen_file
}
alias lstco="lstc_open"
alias lco="lstc_open"

# File browser
alias dir="ranger"

# Timer / Alarms / Time based functions
function notify() {
    if [ $# -eq 2 ]; then
	osascript -e "display notification \"$2\" with title \"$1\" sound name \"Glass\""
    else
        echo "$LOG_ERROR notify requires two parameters (notification body and title)"
    fi
}

function timer() {
  if [ $# -eq 1 ]; then
	  local start=$(date +%s)
	  local goal=$(m "$start+60*$1")
	  echo "Setting up a timer for $1 minutes"
    echo "Start at: $(gdate -d@$start +%H:%M:%S)"
	  echo "Run until $(gdate -d@$goal +%H:%M:%S)"
	  while [ $goal -ge $(date +%s) ];
	  do;
	    local secondsLeft=$(m "$goal-$(date +%s)")
	    echo -en "\r\033[KTimer Left: $(gdate -d@$secondsLeft -u +%H:%M:%S)"
	    sleep 1;
    done;
	  notify "Timer is done" "Timer is done"
	  for i in {1..3}; do afplay /System/Library/Sounds/Glass.aiff; done
    say "Timer is done"
  else
    echo "$LOG_ERROR timer requires one parameter (amount of minutes)"
  fi
}

alias dateiso="date +%F"

# Visual Studio Code Editor Related
alias vscode="code"

# Display current load status
alias mntr="glances"
alias monitor="mntr"

alias maven="mvn"

# CD aliases
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

# Regex functions
function regex_escape() {
  python -c "import re; print(re.escape('$1'))"
}

# String manipulation
function ltrim() {
  if [ $# -eq 1 ]; then
    escaped_input=$(regex_escape $1)
    while read line; do
      echo $line | sed "s~^$escaped_input*~~"
    done
  elif [ $# -eq 2 ]; then
    echo "$1" | ltrim "$2"
  else
    echo "$LOG_ERROR ltrim needs either two args (first one string to trim, second one char to trim) or a single arg (will trim the string consumed from stdin with given char)"
  fi
}

# Clean the screen (leave it empty with the prompt on top of it)
alias cl="printf \"\033c\""
alias clean="cl"

# History (command history related)
alias h="history"
alias hist="history"
function history_grep() {
  if [ $# -eq 1 ]; then
      history | grep $1
  else
      echo "$LOG_ERROR history_grep accepts a single parameter only (what to grep the history for)"
  fi
}
alias hgrep="history_grep"
alias hg="history_grep"

function copy_file_to_clipboard() {
  if [ $# -eq 1 ]; then
      cat $1 | pbcopy
  else
      echo "$LOG_ERROR copy_file_to_clipboard accepts a single parameter only (file path)"
  fi
}

# Hardware CPU amount of cores related
function amount_of_cores() {
  if is_running_on_mac; then
    cores=$(sysctl -n hw.ncpu)
    echo ${cores}
  else
    echo "$LOG_ERROR OS not supported (check zshrc)"
  fi
}
alias cores="amount_of_cores"
alias amount_cores="amount_of_cores"
alias cores_amount="amount_of_cores"

alias ports="sudo lsof -PiTCP -sTCP:LISTEN"

# ZSHRC manipulation
alias sourcezshrc="source $HOME/.zshrc"
alias srczshrc=sourcezshrc
alias editzshrc="$EDITOR $HOME/.zshrc"

# Mail
function check_mail() { $EDITOR /var/mail/$USER }
function clear_mail() { sudo rm /var/mail/$USER }

# Weather
function weather() { curl wttr.in/$1 ; }
function weatherbcn() { weather barcelona ; }
ropa() { # usage: ropa "some city"
    query="$*"
    modified_query="${query// /-}"
    url="https://puedotenderlaropa.com/$modified_query"
    if command -v xdg-open > /dev/null; then
        xdg-open "$url"
    elif command -v open > /dev/null; then
        open "$url"
    else
        echo "Cannot detect a method to open URLs on this system."
    fi
}

# NeoVim aliases
alias n='nvim'

# HTTPie aliases
alias get="http GET"
alias post="http POST"

# Execute last command as sudo
alias please='sudo $(fc -ln -1)'
alias pls=please
alias suda=please

# Command line arithmetic (ej:  `math 10 * 10`)
alias math="amm --silent $PROJECTS_PATH/CLIMath/CLIMath.sc"
alias calc=math
alias calculate=math
alias m=math

function convert_units() {
  local help="Eg: convert_units 3600 seconds hours"
  units "$1 $2" $3
}
alias unit_conversion=convert_units

function remove_decimals () { echo ${1%.*} ; }

# Time and date
function timestamp () { date +%s ; }
function timestamp_milliseconds() { calculate "$(timestamp) * 1000" ; }
function timestamp_to_date () { date -u -r $1 ; }
function timestamp_in_millis_to_date () { timestamp_to_date $(remove_decimals $(calculate "$1 / 1000")); }
function clock() { while :; do printf '%s\r' "$(date)"; sleep 1 ; done ; }
function clock_utc () { while :; do printf '%s\r' "$(date -u)"; sleep 1 ; done ; }
function date_utc () { date -u +%Y-%m-%dT%H:%M:%S ; }
function date_utc_external () { date -u -r $(get http://api.timezonedb.com/v2.1/get-time-zone\?key\=$TIMEZONEDB_API_TOKEN\&format\=json\&by\=zone\&zone\=Africa/Ouagadougou -b | jq -r ".timestamp") +%Y-%m-%dT%H:%M:%S ; }
function utc_difference () { datediff $(date_utc) $(date_utc_external) ; }
