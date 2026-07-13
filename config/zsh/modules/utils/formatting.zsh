#!/bin/zsh
# Formatting, math, time/date utilities

# JSON
alias compress_json="jq -c"
alias json_compress=compress_json

# Math / units
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

# Notifications / timer
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
