# Language flags (set to 1 if you want language specific things to be loaded)
PHP_MODE=0
PYTHON_MODE=1
RUBY_MODE=0
JS_MODE=1
RUST_MODE=1

# Setup zsh with oh-my-zsh
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME=ukelele
ZSH_DISABLE_COMPFIX=true

DISABLE_MAGIC_FUNCTIONS=true # Allow url pasting without escape: https://github.com/ohmyzsh/ohmyzsh/issues/7632
plugins=(zsh-autosuggestions zsh-syntax-highlighting)

# Path constants
export GOPATH="$HOME/golang_workspace"
export PATH="/usr/local/sbin:/usr/local/bin:bin:/usr/sbin:/sbin:$HOME/bin:/usr/bin:$GOPATH/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH" # suggested by pipx
export DOTFILES_PATH="$HOME/.dotfiles"
export MANPATH="/usr/local/man:$MANPATH"

export PROJECTS_PATH="$HOME/projects"

# fpath - path for functions, used for completions 
fpath+=~/.zfunc
autoload -Uz compinit && compinit

eval "$(/opt/homebrew/bin/brew shellenv)"
source $ZSH/oh-my-zsh.sh

if [[ -s $HOME/.secrets ]] ; then source $HOME/.secrets ; fi

export EDITOR='vim'


# Brew constants
export HOMEBREW_AUTO_UPDATE_SECS=25200
export HOMEBREW_NO_ANALYTICS=true
export HOMEBREW_INSTALL_BADGE="(ʘ‿ʘ)"
export HOMEBREW_BUNDLE_FILE_PATH=${DOTFILES_PATH}/Brewfile



# Logging constants
export LOG_ERROR="[Error]"
export LOG_WARNING="[Warning]"
export LOG_INFO="[Info]"


# Locale constants
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# Shell configuration
## Name console window / tab
export DISABLE_AUTO_TITLE="true" # Don't let Oh-My-Zsh control title, control it yourself
set_window_title_to_collapsed_pwd() {
  local _collapsed_pwd=$(pwd | perl -pe "s|^$HOME|~|g; s|/([^/])[^/]*(?=/[^/]*/)|/\$1|g")
  window_title="\e]0;${_collapsed_pwd}\a"
  echo -ne "$window_title"
}
precmd_functions+=(set_window_title_to_collapsed_pwd)

## Add function to evaluate bash's PROMPT_COMMAND variable
prmptcmd() { eval "$PROMPT_COMMAND" }
precmd_functions+=(prmptcmd)

## Autocomplete setup
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''

### Hotfix for slow paste of huge texts - see https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### /Hotfix

## Keybindings- Bindkeys - type 'bindkey' in terminal to check for keyboard shortcuts
bindkey ^A beginning-of-line         # Ctrl+A for moving to beggining
bindkey ^S backward-word             # Ctrl+S for moving a word backward
bindkey ^D forward-word              # Ctrl+D for moving a word forward
bindkey ^F end-of-line               # Ctrl+F for moving till the end
bindkey ^W backward-delete-word      # Ctrl+W to delete a word backward
bindkey ^E kill-word                 # Ctrl+E to delete a word forward

## Use ESC to edit the current command line: https://bugfactory.io/blog/z-shell-tip-edit-current-command-line-with-vim/
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\033' edit-command-line

## 10ms for key sequences: https://www.johnhawthorn.com/2012/09/vi-escape-delays/
KEYTIMEOUT=1

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

## fasd is a command line productivity booster:
##   z -> cd into a directory `z projects`
##   f -> find files
##   a -> find anything
##   d -> find directories
fasd_cache="$HOME/.fasd-cache"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init auto >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

## hstr setup - improved history
export HISTFILE=~/.zsh_history  # ensure history file visibility
export HH_CONFIG=hicolor,keywords,rawhistory
bindkey -s "\C-r" "\eqhh\n"     # bind hh to Ctrl-r (for Vi mode check doc)

## Broot setup - improved tree command
source "$HOME/.config/broot/launcher/bash/br"

# Direnv - environment variables switcher (similar to virtualenv)
eval "$(direnv hook zsh)"

# Fix command line mistakes (write fuck after failing something)
eval $(thefuck --alias)

# Python setup
function setup_python() {
  echo "$LOG_INFO Python mode enabled - setting up python related utilities…"
  # Pyenv setup
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

# Ruby setup
function setup_ruby() {
  echo "$LOG_INFO Ruby mode enabled - setting up ruby related utilities…"
  eval "$(rbenv init -)"
}
  
alias toggle_ruby="setup_ruby"
alias enable_ruby="setup_ruby"
alias ruby_enable=enable_ruby
alias activate_ruby="setup_ruby"

if (($RUBY_MODE)) ; then
  setup_ruby
fi


# PHP setup
function setup_php() {
  DEFAULT_PHP_VERSION="7"
  echo "$LOG_INFO PHP mode enabled - setting up PHP related utilities…"

  ## Php specific aliases
  function php_find_ini() { php --ini ; }
  function phpunit { bin/phpunit ; }
  function phpunit_filter { bin/phpunit --filter $1 ; }
  function phpunitfilter { phpunit_filter ; }
  function behat { bin/behat ; }
  function fix_php_changed_files { gchanged_files | grep .php | xargs phpcbf --standard=PSR2 ; }

}

if (($PHP_MODE)) ; then
  setup_php
fi

# JS (JavaScript) Setup
function setup_js() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

if (($JS_MODE)) ; then
  setup_js
fi

# Scala setup
function kill_sbt() { ps aux | grep java | grep bin/sbt-launch.jar | awk '{print $2}' | xargs kill -9 ; }
alias fucksbt="kill_sbt"
alias killsbt="kill_sbt"

# C# setup
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Rust setup
alias cb="cargo test --no-run --color always 2>&1 | less -r"
alias ct="cargo test"
function cto() { "cargo test --test $1"; }
alias cj="cargo build && cargo fmt --all && cargo clippy --fix --all-targets --allow-dirty --allow-staged && cargo clippy --all-targets -- -D warnings" # Stands for "Cargo Janitor"

function setup_rust() {
  echo "$LOG_INFO Rust mode enabled - setting up Rust related utilities…"
  export CARGO_TARGET_DIR="$HOME/.cargo/cargo_global_target_dir"
  if [ ! -d "$CARGO_TARGET_DIR" ]; then
    mkdir -p "$CARGO_TARGET_DIR"
  fi

  # Run cargo sweep in the background
  if command -v cargo-sweep >/dev/null 2>&1; then
    echo "$LOG_INFO Running cargo sweep in the background..."
    nohup cargo sweep -s "$CARGO_TARGET_DIR" >/dev/null 2>&1 &
  else
    echo "$LOG_WARNING 'cargo-sweep' is not installed. Skipping cleanup."
  fi
}

if (($RUST_MODE)); then
  setup_rust
fi

# PGP/GPG setup
export GPG_TTY=$(tty)


# Service aliases
: '
Standard is:
  - some letters to represent service -> $SERVICE (ej: my for mysql)
  - $SERVICE+cli: open cli to access service (ej: mycli)
  - $SERVICE+init: initialize service in the background
  - $SERVICE+stop: stop the service
  - $SERVICE+restart: stop and initialize the service
  - $SERVICE+check: check if the service is running
  - $SERVICE+cnf: open editor with the service configuration
  - $SERVICE+port: show which open port the service has
'
## MySQL
alias mycli="mycli"
alias myinit="brew services run mysql@5.7"
alias mystop="brew services stop mysql@5.7"
alias myrestart="brew services restart mysql@5.7"
alias mycheck="mysql.server status"
alias myversion="mysql --version"
alias mycnf="$EDITOR /usr/local/etc/my.cnf"

## PostgreSQL
alias pgcli='pgcli'
alias pginit="brew services run postgresql"
alias pgstop="brew services stop postgresql"
alias pgrestart="brew services restart postgresql"

## InfluxDB
alias influxdbcli="influx"
function influxdbinit() { brew services run influxdb ; }
function influxdbstop() { brew services stop influxdb ; }
function influxdbrestart() { brew services restart influxdb ; }
# --- replicate influxdb aliases as influx
alias influxcli="influxdbcli"
function influxinit() { influxdbinit ; }
function influxstop() { influxdbstop ; }
function influxrestart() { influxdbrestart ; }


## Zookeeper aliases
ZOOKEEPER_URL="localhost:2181"
alias zkcli="zkCli"
### TODO zk_random_broker doesn't work with >1 brokers, need to split the string
function zk_random_broker() { zk <<< "ls /brokers/ids" | tail -n 2 | head -n 1 | trim "[]" ; }

## Kafka aliases
function kafka_list_topics() { kafka-topics --zookeeper $ZOOKEEPER_URL --list ; }
function kafka_delete_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --delete --topic $1
  else
      echo "$LOG_ERROR Usage: kafka_delete_topic <TOPIC_NAME>"
  fi
}
function kafka_describe_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --describe --topic $1
  else
      echo "$LOG_ERROR Usage: kafka_describe_topic <TOPIC_NAME>"
  fi
}
function kafka_create_topic() {
  if [ $# -eq 1 ]; then
      kafka-topics --zookeeper $ZOOKEEPER_URL --create --topic $1 --partitions 1 --replication-factor 1
  else
      echo "$LOG_ERROR Usage: kafka_create_topic <TOPIC_NAME>"
  fi
}

# RabbitMQ aliases
function rabbitinit() { brew services run rabbitmq ; }
function rabbitstop() { brew services stop rabbitmq ; }
function rabbitrestart() { brew services restart rabbitmq ; }
function rabbit_list_queues() { rabbitmqadmin list queues ; }
function rabbitcheck() { rabbit_list_queues ; }

# Redis aliases
alias rediscli="redis-cli"
function redisinit() { brew services run redis ; }
function redisstop() { brew services stop redis ; }
function redisrestart() { brew services restart redis ; }
function redischeck() { redis-cli ping ; }
function redisport() { ports | sed -n -e '1p;/redis/p' ; }

# Docker aliases
alias docker_list_active_containers="docker container list"
alias docker_list_stopped_containers="docker ps --filter \"status=exited\""
alias docker_list_all_containers="docker ps -a"
alias docker_list_images="docker image list"
alias docker_start_container="docker container start"
function docker_connect() {
  container=$(docker ps | awk '{if (NR!=1) print $1 ": " $(NF)}' | percol --prompt='<green>Select the container:</green> %q')
  container_id=$(echo $container | awk -F ': ' '{print $1}')
  docker exec -i -t $container_id /bin/bash
}
function docker_stop_all() {
  docker stop $(docker ps -a -q)
}
alias dockerstopall=docker_stop_all

function dps() {
  docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" \
     | awk 'NR == 1; NR > 1 { print $0 | "sort" }';
}
alias dls="dps"
function dpsg() {
  dps | grep $1
}

# Docker-Compose aliases
alias docker-compose-restart="docker-compose rm -s -f && docker-compose up -d"
alias docker_compose_restart=docker-compose-restart

# Apache
function apacherestart() { sudo apachectl restart ; }

# Grafana
function grafanainit() { brew services run grafana ; }
function grafanastop() { brew services stop grafana ; }
function grafanarestart() { brew services restart grafana ; }
function grafanaport() { ports | sed -n -e '1p;/grafana/p' ; }

# Elasticsearch
elasticsearch_version="elasticsearch@5.6"
function esinit() { brew services run $elasticsearch_version ; }
function esstop() { brew services stop $elasticsearch_version ; }
function esrestart() { brew services restart $elasticsearch_version ; }
function esport() {
  es_status=$(get http://localhost:9200/_cluster/health | jq -r '{message: .status} | "\(.message)"')
  if [[ "$es_status" == "green" ]]; then
    echo "9200"
  else
    echo "$LOG_ERROR elastic search seems to not be running on port 9200 (or it might be just starting, try again?)"
  fi
}
function escheck() {
  es_status=$(get http://localhost:9200/_cluster/health | jq -r '{message: .status} | "\(.message)"')
  if [[ "$es_status" == "green" ]]; then
    echo "Status: OK"
  else
    echo "$LOG_ERROR elastic search seems to not be running on port 9200 (or it might be just starting, try again?)"
  fi
}
function escnf() { $EDITOR /usr/local/etc/elasticsearch/elasticsearch.yml ; }
function esplugin() { /usr/local/opt/elasticsearch@5.6/libexec/bin/elasticsearch-plugin $@ ; }

# AWS
export AWS_PROFILE=saml

# Internet / Connectivity
function is_connected_to_internet {
  wget -q --tries=10 --timeout=20 --spider http://google.com
  echo "$?"
}

function assert_internet_connectivity {
  if [[ $(is_connected_to_internet) -eq 0 ]]; then
      # We're online
  else
      echo "Internet seems to be down, aborting..."
      kill -INT $$
  fi
}

function restart_networking {
  sudo ifconfig en0 down
  sudo ifconfig en0 up
}

alias pingg="ping www.google.com"


# Deal with documents/files (files management, working with files)
function extract {
  # Extract contents from compressed file in multiple formats
  if [ -z "$1" ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|exe|tar.bz2|tar.gz|tar.xz|.jar>"
  else
    if [ -f "$1" ] ; then
      NAME=${1%.*}
      case "$1" in
        *.tar.bz2)   tar xvjf ./"$1"    ;;
        *.tar.gz)    tar xvzf ./"$1"    ;;
        *.tar.xz)    tar xvJf ./"$1"    ;;
        *.lzma)      unlzma ./"$1"      ;;
        *.bz2)       bunzip2 ./"$1"     ;;
        *.rar)       unrar x -ad ./"$1" ;;
        *.gz)        gunzip ./"$1"      ;;
        *.tar)       tar xvf ./"$1"     ;;
        *.tbz2)      tar xvjf ./"$1"    ;;
        *.tgz)       tar xvzf ./"$1"    ;;
        *.zip)       unzip ./"$1"       ;;
        *.Z)         uncompress ./"$1"  ;;
        *.7z)        7z x ./"$1"        ;;
        *.xz)        unxz ./"$1"        ;;
        *.exe)       cabextract ./"$1"  ;;
        *.jar)       jar xf ./"$1"      ;;
        *)           echo "extract: '$1' - unknown archive method" ;;
      esac
    else
        echo "'$1' - file does not exist"
    fi
  fi
}

function encrypt_pdf {
  if [ -z "$1" ]; then
    echo "Usage: encrypt_pdf <path/file_name>"
  else
    if [ -f "$1" ] ; then
      qpdf --encrypt $DOCUMENTATION_PW $DOCUMENTATION_PW 128 --use-aes=y -- $1 tmp.pdf
      rm $1
      mv tmp.pdf $1
    else
      echo "'$1' - file does not exist"
    fi
  fi
}

function convert_image_to_pdf {
  if [ -z "$1" ]; then
    echo "Usage: convert_image_to_pdf <path/file_name>"
  else
    if [ -f "$1" ] ; then
      local filename=$(echo $1 | sed "s/\(.*\)\..*/\1/")
      sips -s format pdf $1 --out $filename.pdf
    else
      echo "'$1' - file does not exist"
    fi
  fi
}

function encrypt_image_as_pdf {
  local pdfname="$(echo $1 | sed "s/\(.*\)\..*/\1/").pdf"
  convert_image_to_pdf $1
  encrypt_pdf $pdfname
  rm $1
}

function encrypt_zip {
  if [ -z "$1" ]; then
    echo "Usage: encrypt_zip <path/file_name>"
  else
    if [ -f "$1" ]; then
      if [[ "$1" == *.zip ]]; then
        # If the file is already a zip, unzip, re-zip with password, and remove original zip
        temp_dir=$(mktemp -d)
        unzip -q "$1" -d "$temp_dir"
        zip -r -P $DOCUMENTATION_PW "$1" "$temp_dir"/*
        rm -rf "$temp_dir"
      else
        # If it's a regular file, zip it with a password and remove the original file
        zip -P $DOCUMENTATION_PW "$1.zip" "$1"
        rm "$1"
      fi
    elif [ -d "$1" ]; then
      # If it's a directory, zip it with a password and remove the original directory
      zip -r -P $DOCUMENTATION_PW "$1.zip" "$1"
      rm -r "$1"
    else
      echo "'$1' - file or directory does not exist"
    fi
  fi
}


function optimize_clipboard_image () {
  rm /tmp/test.png
  pngpaste /tmp/test.png
  pngquant 64 --skip-if-larger --strip --ext=.png --force /tmp/test.png
  # zopflipng -y /tmp/test.png /tmp/test.png
  osascript -e "set the clipboard to (read (POSIX file \"$(perl -e "print glob('/tmp/test.png')")\") as {«class PNGf»})"
  echo "Image is optimized :)"
}


function current_directory_size {
  du -h $(pwd) | tail -n 1
}

# Subtitles
function subtitles() {
  assert_internet_connectivity
  if [ -z "$1" ]; then
    echo "Usage: subtitles <file_path>"
  else
    subliminal --opensubtitles $OPENSUBTITLES_USER $OPENSUBTITLES_PW download -l es -l en $1
  fi
}

function subtitles_dir() {
  assert_internet_connectivity
  if [ -z "$1" ]; then
    echo "Usage: subtitles_dir <dir_path>"
  else
    echo "Downloading subtitles in parallel..."
    find "$1" -maxdepth 1 -type f | subliminal --opensubtitles $OPENSUBTITLES_USER $OPENSUBTITLES_PW download -l es -l en {} \;
  fi
}

function benchmark_shell() {
  for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done
}

function echo_return_code() {
  echo $?
}

## Get .gitignore info easily - ej: gi python,java,linux,osx
function fetch_gitignore() {
    curl -L -s https://www.gitignore.io/api/$@ | sed '/^# Created/ d' | sed '/./,$!d' | sed $'1s/^/\\\n/'
}
alias gi="fetch_gitignore"

function is_running_on_mac() {
  if [[ `uname` == "Darwin" ]]; then
    return true
  else
    return false
  fi
}

function mkcdir() {
    mkdir -p "$1" && cd "$1"
}

function randomuuid() {	echo $(uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]') ; }
function uuidcp() { randomuuid | tr -d '\n' | pbcopy && pbpaste && echo ; }

function randomcowsay() {
  cow=(`cowsay -l | tail -n +2 | tr  " "  "\n" | sort -R | head -n 1`)
  cowsay -f $cow "$@"
}

# Find / Search files or file contents related
function searchfaq() { 
  FAQ=$(cat <<-END
SEARCH HELP
=================================
- fs (filesearch): search for a file with given substring by name, in current directory tree
    ej: fs
    ej: fs email 
- fso (file search and open): search and open a file by name
    ej: fso
    ej: fso email
- fsc (file search inside contents): search inside file contents for a given string
    ej: fsc email
- fsc2 (file search inside contents 2 files): search for files which contain both inputs
    ej: fsc2 email repository
- fsg (file search globally by name)
    ej: fsg my.cnf

- fd: use it to find files (output as a list)
END
  )
  echo "$FAQ"
}

function filesearch() { 
  if [ $# -eq 1 ]; then
    fzf --height 40% -q $1
  else
    fzf --height 40% 
  fi
}
alias fs=filesearch

function search_and_open() {
  local find_result=$(fs)
  if [[ ! -z "$find_result" ]]; then
    $EDITOR $find_result
    echo "File opened: $find_result"
  fi
}
alias fso=search_and_open

function search_in_content() { rg $1 ; }
alias fsc=search_in_content

function search_in_content_two_independent_words() { rg $1 -l -0 | xargs -0 rg $2 -l ; }
alias fsc2=search_in_content_two_independent_words

function find_by_name_globally() {
  if [ $# -eq 1 ]; then
    fd -HI "$1" / | fzf
  else
      echo "$LOG_ERROR find_by_name_globally accepts a single parameter only (what to find for)"
  fi
}
alias fsg="find_by_name_globally"

# Notes related
function new_note() {
  if [ $# -eq 1 ]; then
    formatted_date=$(date '+%Y-%m-%d')
    $EDITOR "$formatted_date-$1.md"
  else
      echo "$LOG_ERROR new_note accepts a single parameter only (note name)"
  fi
}
alias n="new_note"



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

# Vim aliases
alias vim_install_plugins="vim +PluginInstall +qall"
alias vim_plugin_update=vim_install_plugins

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

# kubernetes k8s related aliases and helper functions
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgsec="kubectl get secret"
alias kgd="kubectl get deployments"
alias kservices="kubectl get services"

function kcurrent() { echo "$(kcurrent_context) / $(kcurrent_namespace)"; }
alias kc="kcurrent"
function kcurrent_context() { kubectl config current-context; }
function kcurrent_namespace() { kubens --current; }
function kchangecontext() { kubectx ; }
function kctx () { kubectx ; }
function kcontext () { kubectx ; }
function kchangenamespace() { kubens ; }
function knamespace() { kubens ; }
function kns() { kubens ; }

function kdecode_secret() {
  percol_secret_selection=$(kubectl get secret | percol --prompt='<green>Select secret to decode:</green> %q')
  local selected_secret=$(echo $percol_secret_selection | cut -d" " -f1)
  echo "Selected secret: $selected_secret"
  kubectl get secret $selected_secret -o json | jq '.data | map_values(@base64d)'
}

## GIT ALIASES AND HELPER FUNCTIONS
alias gp="git push"
alias gpf="git push --force-with-lease"
alias gpfn="git push --force-with-lease --no-verify"
alias gpumaster="git push upstream HEAD:master"  # Pushes current branch to upstream master
alias gpoh="git push origin HEAD"  # Push current branch to a branch with same name on the remote (useful after creating new branch)
alias gp_same_name="gpoh"
alias gp_skip_hooks="git push --no-verify"
alias gpskiphooks="git push --no-verify"
alias gp_no_hooks="git push --no-verify"
alias gpnohooks="git push --no-verify"
alias gpn="git push --no-verify"
alias gpt="git push --tags"

alias gck="git checkout"
alias gckm="git checkout master"
alias gckd="git checkout develop"
alias gckb="git checkout -b"
alias gckt="git checkout --theirs"
alias gcko="git checkout --ours"
alias gckmine="git checkout --ours" # Checkout the file I already had (compared to server)
alias gdiscard_unstaged="git checkout -- ."
alias gck_unstaged="git checkout -- ."
alias gckunstaged="git checkout -- ."
function function gckl_all() {
  percol_branch_selection=$(git branch --sort=-committerdate -a | percol --prompt='<green>Select branch to checkout:</green> %q')
  branch=$(echo $percol_branch_selection | ltrim "*" | ltrim " " | sed 's/^remotes\/.*\///')
  git checkout $branch
}
function gckl() {
  percol_branch_selection=$(git branch --sort=-committerdate | percol --prompt='<green>Select branch to checkout:</green> %q')
  branch=$(echo $percol_branch_selection | ltrim "*" | ltrim " " | sed 's/^remotes\/.*\///')
  git checkout $branch
}

alias gs="git status"
alias gsa="git status -uall"
alias gas="gsa" # Typo

alias gpr="gh pr create"
alias gprl="git pr list -f '%i - %t%n%U%n%l%nBy: %au @ %H%n%n'"
alias gpropen="gh pr view --web"
alias gbrowsepr="gpropen"
alias gprbrowse="gpropen"
alias grepo="gh repo view -w"
alias grepoview="grepo"
alias grepobrowse="grepo"
alias grepob="grepo"

function greposearch() {
  local organization=$1
  local percol_repo_selection=$(gh repo list $organization --limit 1000 | percol --prompt='<green>Select repo to open:</green> %q')
  local repo=$(echo "$percol_repo_selection" | awk '{ print $1 }')
  open "https://www.github.com/$repo"
}
function gclonecd () {
  repo_url="$1"
  dir_name=$(basename "$repo_url" .git)
  git clone "$repo_url"
  cd "$dir_name"
}

alias gf="git fetch"
alias gfetch="git fetch"
alias gfa="git fetch --all"
alias gfo="git fetch origin"
alias gfu="git fetch upstream"
alias gfupstream="git fetch upstream"

alias gfommerge="git fetch origin && git merge origin/master"
alias gfomrebase="git fetch origin && git rebase origin/master"
alias gfodmerge="git fetch origin && git merge origin/develop"
alias gfodrebase="git fetch origin && git rebase origin/develop"

alias gpl="git pull"
alias gplr="git pull --rebase"

alias ga="git add"
alias gaa="ga ."  # Git add all
alias ga.="ga ."

alias gunstage_all="git restore --staged ."

alias gnvm="git nvm"
alias gnevermind="git nevermind"

alias grc="git rebase --continue"

alias grp="git remote prune origin"  # Remove branches locally that have already been deleted in the remote
alias gprune="grp"
alias grinfo="git remote | xargs git remote show"
alias grshow_all="grinfo"
function gmaintenance() {
  # Switch to a head branch
  git remote show origin | grep "HEAD branch" | cut -d ":" -f 2 | xargs git checkout
  gpl
  git remote prune origin
  # Store gone branches
  git branch -vv | grep ': gone]'|  grep -v "\*" | awk '{ print $1; }' > /tmp/gmaintenance.txt 

  if [ -s /tmp/gmaintenance.txt ]; then
    # Give some room to edit branches
    vim /tmp/gmaintenance.txt

    # Delete them
    xargs git branch -D </tmp/gmaintenance.txt
  fi
}

function gcurrent_branch_name() { git rev-parse --abbrev-ref HEAD ; }
alias git_branch_name=gcurrent_branch_name
alias gbname=gcurrent_branch_name

function gcurrent_commit_hash_cp() {
  echo "Hash was copied from commit: "	
  echo ""
  git --no-pager log -n 1 
  git rev-parse HEAD | tr -d '\n' | pbcopy
};

alias gchashcp=gcurrent_commit_hash_cp
alias gcommit_hash_cp=gcurrent_commit_hash_cp
alias ghashcp=gcurrent_commit_hash_cp
alias gcopylastcommithash=gcurrent_commit_hash_cp
alias gcopy_last_commit_hash=gcurrent_commit_hash_cp
alias gcplastcommithash=gcurrent_commit_hash_cp
alias glastcommithashcp=gcurrent_commit_hash_cp

alias grh="git reset --hard"
function grh_same_branch_origin() { git reset --hard "origin/$(gcurrent_branch_name)" ; }

alias grm_deleted_files="git ls-files --deleted -z | xargs -0 git rm"  # Git rm files that have been deleted

alias gl="git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(green)%d%Creset %s %C(magenta)(%cr) %C(cyan)<%an>%Creset' --abbrev-commit"

alias gnuke_last_commit="git reset --keep HEAD~1"
alias gnevermind="git nevermind"  # Remove all the changes you've made

alias gstash="git stash"
function gstash_list() { git stash list ; }
alias gsl=gstash_list
function gstash_clear() { git stash clear ; }
function gstashs() {
  if [ $# -eq 1 ]; then
    git stash save "$1"
  else
    echo "$LOG_ERROR gstashs (git stash save) accepts a single parameter only (stash name)"
  fi
}
function gstash_save() { gstashs ; }
function gstash_save_current_branch_name() { gstashs $(gcurrent_branch_name) ; }
alias gunstash="git unstash"

function gsquash_master() { git rebase -i origin/master }
function gsquash_same_branch() { git rebase -i origin/$(gcurrent_branch_name) }
alias grm="git rebase master"
alias grom="git fetch && git rebase origin/master"
alias grum="git rebase upstream/master"
alias grupstream_master="git rebase upstream/master"

alias gdh="git diff HEAD"
alias gdh1="git diff HEAD~1"
alias gdh2="git diff HEAD~2"
alias gdh3="git diff HEAD~3"
alias gdh4="git diff HEAD~4"
alias gdh5="git diff HEAD~5"
alias gdh6="git diff HEAD~6"
alias gdh7="git diff HEAD~7"
alias gdh8="git diff HEAD~8"
alias gdh9="git diff HEAD~9"
alias gdhs="git diff HEAD --stat"
alias gdhunity='git diff HEAD -- . ":(exclude)*.dwlt" ":(exclude)*.prefab" ":(exclude)*.unity" ":(exclude)*.meta" ":(exclude)*.asset" ":(exclude)*.png" ":(exclude)*.PNG" ":(exclude)*.dwlt"'
function gdmaster() { git diff remotes/origin/master..$(gcurrent_branch_name) }
alias gdm=gdmaster
alias gdmaster_name_status="gdmaster --name-status"
function gdupstream_master { git diff upstream/master $(gcurrent_branch_name) }
alias gdum=gdupstream_master
function gddevelop() { git diff remotes/origin/develop..$(gcurrent_branch_name) }
alias gdd=gddevelop
alias gtodo="git diff-index --name-only -U --cached -G TODO HEAD" # Find files that contain "TODO" in last index (remember to add the files!)

alias gb="git branch"
alias gba="git branch -a"
alias gbr="git branch -r"
alias gbd="git branch -d"
alias gbD="git branch -D --"
alias gbd_remote="git push origin --no-verify --delete"
function git_branch_rename_local() {
  if [ "$#" -gt 1 ]; then
    echo "Error: Too many parameters. Only one parameter is allowed." >&2
    return 1
  elif [ "$#" -eq 1 ]; then
    new_branch_name="$1"
  else
    echo "$(gcurrent_branch_name)" > /tmp/git_branch_name_for_rename.txt
    vim /tmp/git_branch_name_for_rename.txt
    new_branch_name=$(cat /tmp/git_branch_name_for_rename.txt)
  fi

  git branch -m "$new_branch_name"
}
alias gbrename=git_branch_rename_local
alias grename_branch=git_branch_rename_local
function gbset_upstream_to_same_branch_in_origin() {
  current_branch_name=$(gcurrent_branch_name)
  git branch --set-upstream-to=origin/$current_branch_name $current_branch_name
}
function git_branch_exists_filter() {
  # Function meant to be used as unix pipes filter (reading from stdin)
  # input = branch names
  # output = same branch name if exists, nothing (no output) if it does not
  while IFS= read -r line; do
    local trimmed=$(echo $line | tr -d '\n')
    git rev-parse --verify $trimmed &> /dev/null
    if [[ $? == 0 ]]; then
      echo "$trimmed"
    fi
  done
}



alias gc="git commit"
alias gca="gc --amend"
alias gcamend="gca"
alias gcammend="gca"
alias gamend="gca"
alias gammend="gca"
git_commit_with_msg () {
    if [ $# -eq 0 ]; then
        echo "$LOG_ERROR gcm needs at least one parameter (the commit message)"
        return 1
    fi

    # "$*" joins all parameters with spaces, preserving their exact spelling & case
    local msg="$*"
    git commit -m "$msg"
}
alias gcm=git_commit_with_msg
alias gcn="git commit --no-verify"
alias gc_skip_hooks="git commit --no-verify"
alias gc_no_checks="git commit --no-verify"
function git_commit_no_verify_with_msg() {
  if [ $# -eq 1 ]; then
      echo "$LOG_WARNING Skipping commit hooks!"
      git commit --no-verify -m $1
  else
      echo "[Error] git_commit_no_verify_with_msg accepts a single parameter only (the commit message)"
  fi
}
alias gcnm=git_commit_no_verify_with_msg
alias gcmn=git_commit_no_verify_with_msg
function git_empty_commit() {
  git commit --allow-empty -m "This is an empty commit"
}
alias git_commit_empty=git_empty_commit
alias gempty=git_empty_commit
alias gcempty=git_empty_commit
function gcbname() {
  # Applies a commit with the same name as the current branch name transformed to sentence case
  local branch_name=$(gbname)  
  local commit_message=$(case_converter -f snake -t sentence $branch_name) 
  gcm "$commit_message"
}
alias gcwip="gcm \"WIP\""
alias gcmwip=gcwip
alias guncommit="git uncommit" # resets last commit
alias greset_last_commit="git uncommit"

function git_changed_files() { git diff --name-only HEAD~1 ; }
alias gchanged_files=git_changed_files

function gmerge_origin_master { git fetch && git merge origin/master ; }
function gmerge_upstream_master { git fetch && git merge upstream/master ; }
function gmerge_master { git merge master ; }
alias gmum=gmerge_upstream_master
alias gmom=gmerge_origin_master
function gabort_merge { git merge --abort ; }

function git_integrate_multiple() {
  local starting_branch=$(gbname)
  local oldest_commit=$(gl | percol --prompt="select OLDEST commit to pick for cherry-pick" | trim "*" | trim " " | cut -d " " -f1)
  local most_recent_commit=$(gl | percol --prompt="select MOST RECENT commit to pick for cherry-picking (first one was $oldest_commit)" | trim "*" | trim " " | cut -d " " -f1)
  vared -p 'Input branch name for the new branch to be created: ' -c branch_name

  echo ">>>>>> Checking out master and getting it updated..."
  git checkout master
  git pull
  echo ">>>>>> Done!"

  echo " "

  echo ">>>>>> Checking out a new branch called '$branch_name', cherry-picking and pushing it..."
  git checkout -b $branch_name
  git cherry-pick "$oldest_commit^..$most_recent_commit"
  git push
  echo ">>>>>> Done!"

  echo " "

  echo ">>>>>> Going back to the original branch, which was '$starting_branch'"
  git checkout $starting_branch

  echo ">>>>>> We're finished, thanks for doing a small pull request!"
}
alias gintegrate_multiple=git_integrate_multiple

function git_integrate_single() {
  local starting_branch=$(gbname)
  local commit_hash=$(gl | percol --prompt="select SINGLE commit to pick for cherry-pick" | trim "*" | trim " " | cut -d " " -f1)

  echo "Picked out commit with hash $commit_hash"
  echo "Commit message: $(git log --format=%B -n 1 $commit_hash)"
  vared -p 'Input branch name for the new branch to be created: ' -c branch_name

  echo ">>>>>> Checking out master and getting it updated..."
  git checkout master
  git pull
  echo ">>>>>> Done!"

  echo " "

  echo ">>>>>> Checking out a new branch called '$branch_name', cherry-picking and pushing it..."
  git checkout -b $branch_name
  git cherry-pick "$commit_hash"
  git push
  echo ">>>>>> Done!"

  echo " "

  echo ">>>>>> Going back to the original branch, which was '$starting_branch'"
  git checkout $starting_branch

  echo ">>>>>> We're finished, thanks for doing a small pull request!"
}
alias gintegrate_single=git_integrate_single

# Git machete aliases
alias gms="git machete status"
alias gmt="git machete traverse --fetch"
alias gmadd="git machete add"
alias gmadvance="git machete advance"
alias gmurebase="git machete update -n"
alias gmumerge="git machete update --merge -n"
alias gmtallrebase="git machete traverse --fetch --whole"
alias gmtallmerge="git machete traverse --fetch --whole --merge"
alias gmedit="git machete edit"

# Greeting Message
function greeting() {
  fortune | randomcowsay | lolcat -F 0.05
}
touch ~/.hushlogin # Disable the 'Last login: .....' message that appears as the first line on a new shell.
greeting

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/gerard/.sdkman"
[[ -s "/Users/gerard/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/gerard/.sdkman/bin/sdkman-init.sh"

