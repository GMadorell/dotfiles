# Language flags (set to 1 if you want language specific things to be loaded)
PHP_MODE=0
PYTHON_MODE=0

# Setup zsh with oh-my-zsh
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME=ukelele

plugins=(git gitfast git-extras colored-man colorize brew osx zsh-autosuggestions zsh-syntax-highlighting)

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/bin:$PATH"
export PATH="$HOME/anaconda/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

if [[ -s $HOME/.secrets ]] ; then source $HOME/.secrets ; fi

export EDITOR='vim'


# Logging constants
export LOG_ERROR="[Error]"
export LOG_WARNING="[Warning]"
export LOG_INFO="[Info]"


# Shell configuration
## Name console window / tab
export DISABLE_AUTO_TITLE="true" # Don't let Oh-My-Zsh control title, control it yourself
set_window_title_to_collapsed_pwd() {
  local _collapsed_pwd=$(pwd | perl -pe "s|^$HOME|~|g; s|/([^/])[^/]*(?=/[^/]*/)|/\$1|g")
  window_title="\e]0;${_collapsed_pwd}\a"
  echo -ne "$window_title"
}
precmd_functions+=(set_window_title_to_collapsed_pwd)

## Autocomplete setup
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''

## Keybindings- Bindkeys - type 'bindkey' in terminal to check for keyboard shortcuts
bindkey ^A beginning-of-line         # Ctrl+A for moving to beggining
bindkey ^S backward-word             # Ctrl+S for moving a word backward
bindkey ^D forward-word              # Ctrl+D for moving a word forward
bindkey ^F end-of-line               # Ctrl+F for moving till the end
bindkey ^W backward-delete-word      # Ctrl+W to delete a word backward
bindkey ^E kill-word                 # Ctrl+E to delete a word forward

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

# Python setup
if (($PYTHON_MODE)) ; then
  echo "$LOG_INFO Python mode enabled - setting up python related utilities…"

  ## Virtualenvwrapper
  mkdir -p $HOME/.envs
  export WORKON_HOME=$HOME/envs
  if [[ -s /usr/local/bin/virtualenvwrapper_lazy.sh ]] ; then
    echo "$LOG_INFO Setting up virtualenvwrapper…"
    source /usr/local/bin/virtualenvwrapper_lazy.sh ;
  else
    echo "$LOG_WARNING Virtualenvwrapper is not setup correctly"
  fi

  ## Python specific aliases
  function nose_parallel() {
    # Nose is a testing framework for python
    twice_amount_of_cores="$(($(amount_of_cores) * 2))"
    nosetests --processes=${twice_amount_of_cores} --process-timeout=45
  }
fi

# PHP setup
if (($PHP_MODE)) ; then
  DEFAULT_PHP_VERSION="7"
  echo "$LOG_INFO PHP mode enabled - setting up PHP related utilities…"

  ## Php-version setup
  if [[ -s $(brew --prefix php-version)/php-version.sh ]] ; then
    echo "$LOG_INFO Using default php-version: $DEFAULT_PHP_VERSION"
    source $(brew --prefix php-version)/php-version.sh && php-version $DEFAULT_PHP_VERSION
  else
    echo "$LOG_WARNING php-version is not setup correctly"
  fi

  ## Php specific aliases
  function php_find_ini() { php --ini ; }
  function phpunit { bin/phpunit ; }
  function phpunit_filter { bin/phpunit --filter $1 ; }
  function phpunitfilter { phpunit_filter ; }
  function behat { bin/behat ; }
  function fix_php_changed_files { gchanged_files | grep .php | xargs phpcbf --standard=PSR2 ; }
fi



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
alias myinit="mysql.server start"
alias myrestart="mysql.server restart"
alias mycheck="mysql.server status"
alias myversion="mysql --version"
alias mycnf="$EDITOR /usr/local/etc/my.cnf"

## PostgreSQL
alias pgcli='pgcli'
LOCAL_POSTGRES_DB_PATH="/usr/local/var/postgres"
alias pginit="pg_ctl -D $LOCAL_POSTGRES_DB_PATH start"
alias pgrestart="pg_ctl -D $LOCAL_POSTGRES_DB_PATH restart"

## InfluxDB
alias influxdbcli="influx"
function influxdbinit() { nohup influxd > /dev/null 2>&1 & ; }
function influxdbstop() { pkill influxd ; }
function influxdbrestart() {
  influxdbstop
  influxdbinit
}

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
function rabbitinit() { rabbitmq-server run -detached; }
function rabbitstop() { rabbitmqctl stop; }
function rabbitrestart() { rabbitstop && rabbitstart; }
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

# Helper functions and aliases

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

function subtitles() {
  assert_internet_connectivity
  if [ -z "$1" ]; then
    echo "Usage: subtitles <file_path>"
  else
    subliminal download -l en -l es $1
  fi
}

function subtitles_dir() {
  assert_internet_connectivity
  if [ -z "$1" ]; then
    echo "Usage: subtitles_dir <dir_path>"
  else
    echo "Downloading subtitles in parallel..."
    find "$1" -maxdepth 1 -type f | parallel subliminal download -l en -l es {} \;
  fi
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

function uuidcp() { uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]'  | pbcopy && pbpaste && echo ; }


# Find / Search files or file contents related
function find_by_name_globally() {
  if [ $# -eq 1 ]; then
    sudo find / -iname "$1"
  else
      echo "$LOG_ERROR find_by_name_globally accepts a single parameter only (what to find for)"
  fi
}
alias find_global="find_by_name_globally"

function fuzzyfind() { fzf --height 40% ; }
alias filefind=fuzzyfind
alias ff=fuzzyfind
alias fzfind=fuzzyfind
alias fuzzysearch=fuzzyfind
alias fzsearch=fuzzysearch
alias fzs=fuzzysearch
alias fs=fuzzysearch
function fuzzyopen() {
  local find_result=$(fuzzyfind)
  if [[ ! -z "$find_result" ]]; then
    $EDITOR $find_result
    echo "File opened: $find_result"
  fi
}
alias fzopen=fuzzyopen
alias fzo=fuzzyopen

function search_in_files() { rg $1 ; }
alias sif=search_in_files
alias search_in_content=search_in_files
alias search_content=search_in_files
alias searchcontent=search_in_files
alias sic=search_in_files

# Hardware related
## Battery status
function mouse_battery_percentage() {
  echo $(ioreg -n AppleDeviceManagementHIDEventService | grep -i batterypercent | sed 's/[^[:digit:]]//g')
}

alias copy="pbcopy"
alias paste="pbpaste"
alias cbcopy=copy
alias cbpaste=paste

alias lst="exa -l -h -a -a --time-style long-iso"  # This should be the default to list files, abstracting away the used tool
alias lst_date_created="exa -l -h -t created --sort created -a -a --time-style long-iso"
alias lst_created="lst_date_created"
alias lstcreated="lst_data_created"
alias lstc="lst_date_created"
alias lst_date_modified="exa -l -h -t modified --sort modified -a -a --time-style long-iso"
alias lst_modified="lst_date_modified"
alias lstmodified="lst_date_modified"
function ls_grep() {
    if [ $# -eq 1 ]; then
        lst | grep --ignore-case $1
    else
        echo "$LOG_ERROR ls_grep accepts a single parameter only (what to grep the ls result for)"
    fi
}
alias lg="ls_grep"
alias lsg="ls_grep"


# Display current load status
alias mntr="gtop"
alias monitor="mntr"

alias clean="clear"

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
alias cdp="cd ~/projects/"
alias cddownloads="cd ~/downloads/"

alias cl="printf \"\033c\""

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

alias sourcezshrc="source $HOME/.zshrc"
alias srczshrc=sourcezshrc
alias editzshrc="$EDITOR $HOME/.zshrc"

function check_mail() { $EDITOR /var/mail/$USER }
function clear_mail() { sudo rm /var/mail/$USER }

# HTTPie aliases
alias get="http GET"
alias post="http POST"

# Execute last command as sudo
alias please='sudo $(fc -ln -1)'
alias pls=please
alias suda=please

# Command line arithmetic (ej:  `calculate 10 * 10`)
function calculate () {
  comma_less_args=$(echo "$@" | sed "s/,//g")
  bc -l <<< "scale=3; $comma_less_args"
}
alias calc=calculate
alias math=calculate

## GIT ALIASES AND HELPER FUNCTIONS
alias git="hub"
alias gp="git push"
alias gpf="git push --force"
alias gpfn="git push --force --no-verify"
alias gpumaster="git push upstream HEAD:master"  # Pushes current branch to upstream master
alias gpoh="git push origin HEAD"  # Push current branch to a branch with same name on the remote (useful after creating new branch)
alias gp_same_name="gpoh"
alias gp_skip_hooks="git push --no-verify"
alias gpskiphooks="git push --no-verify"
alias gp_no_hooks="git push --no-verify"
alias gpnohooks="git push --no-verify"
alias gpn="git push --no-verify"

alias gck="git checkout"
alias gckb="git checkout -b"
alias gckt="git checkout --theirs"
alias gcko="git checkout --ours"
alias gckmine="git checkout --ours" # Checkout the file I already had (compared to server)
alias gdiscard_unstaged="git checkout -- ."
alias gck_unstaged="git checkout -- ."
alias gckunstaged="git checkout -- ."

alias gs="git status"
alias gsa="git status -uall"

alias gpr="git pull-request"

alias gf="git fetch"
alias gfetch="git fetch"
alias gfa="git fetch --all"
alias gfu="git fetch upstream"
alias gfupstream="git fetch upstream"

alias gpl="git pull"
alias gplr="git pull --rebase"

alias ga="git add"
alias gaa="ga ."  # Git add all
alias ga.="ga ."

alias grp="git remote prune origin"  # Remove branches locally that have already been deleted in the remote
alias gprune="grp"
alias grinfo="git remote | xargs git remote show"
alias grshow_all="grinfo"
alias grmmerged="git branch --merged master | grep -v 'master$' | xargs git branch -d"  # Remove local branches that have already been merged into master
alias gprune_and_remove_merged="gprune && grmmerged"
alias gmaintenance="gprune && grmmerged"

function gcurrent_branch_name() { git rev-parse --abbrev-ref HEAD ; }
alias git_branch_name=gcurrent_branch_name
alias gbname=gcurrent_branch_name

alias grm_deleted_files="git ls-files --deleted -z | xargs -0 git rm"  # Git rm files that have been deleted

alias gl="git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(green)%d%Creset %s %C(magenta)(%cr) %C(cyan)<%an>%Creset' --abbrev-commit"

alias gnuke_last_commit="git reset --hard HEAD~1"
alias gnevermind="git nevermind"  # Remove all the changes you've made

alias gstash="git stash"
function gstash_list() { git stash list ; }
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
function gdmaster() { git diff remotes/origin/master..$(gcurrent_branch_name) }
alias gdmaster_name_status="gdmaster --name-status"
function gdupstream_master { git diff upstream/master $(gcurrent_branch_name) }
alias gdum=gdupstream_master

alias gb="git branch"
alias gbd="git branch -d"
alias gbD="git branch -D --"
alias gbd_remote="git push origin --no-verify --delete"
function git_branch_rename_local() {
    if [ $# -eq 1 ]; then
        git branch -m $1
    else
        echo "$LOG_ERROR git_branch_rename_local accepts a single parameter only (the new branch name)"
    fi
}
alias gbrename=git_branch_rename_local
alias grename_branch=git_branch_rename_local
function gbset_remote_to() {
  # $1 expected to be of the form remote/branch
  if [ $# -eq 1 ]; then
      git branch "$gcurrent_branch_name" --set-upstream-to $1
  else
      echo "$LOG_ERROR gbset_remote_to accepts a single parameter only (the remote)"
  fi
}

alias gc="git commit"
alias gca="gc --amend"
alias gcamend="gca"
alias gcammend="gca"
alias gamend="gca"
alias gammend="gca"
function git_commit_with_msg() {
    if [ $# -eq 1 ]; then
        git commit -m $1
    else
        echo "$LOG_ERROR gcm accepts a single parameter only (the commit message)"
    fi
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

function git_changed_files() { git diff --name-only HEAD~1 ; }
alias gchanged_files=git_changed_files

function gmerge_upstream_master { git merge upstream/master ; }
function gmerge_master { git merge master ; }
alias gmum=gmerge_upstream_master
function gabort_merge { git merge --abort ; }
function gmerge_abort { git merge --abort ; }
