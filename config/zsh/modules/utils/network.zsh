#!/bin/zsh
# Network connectivity and external-service utilities

function is_connected_to_internet {
  wget -q --tries=10 --timeout=20 --spider http://google.com
  echo "$?"
}

function assert_internet_connectivity {
  if [[ $(is_connected_to_internet) -eq 0 ]]; then
    true
  else
    echo "Internet seems to be down, aborting..."
    kill -INT $$
  fi
}

function restart_networking {
  sudo ifconfig en0 down
  sudo ifconfig en0 up
}

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
