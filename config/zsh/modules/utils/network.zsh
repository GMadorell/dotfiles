#!/bin/zsh
# Network connectivity checks and management

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
