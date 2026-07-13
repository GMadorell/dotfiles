#!/bin/zsh
# Hardware information and system utilities

function mouse_battery_percentage() {
  echo $(ioreg -n AppleDeviceManagementHIDEventService | grep -i batterypercent | sed 's/[^[:digit:]]//g')
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

function is_running_on_mac() {
  if [[ `uname` == "Darwin" ]]; then
    return true
  else
    return false
  fi
}

function benchmark_shell() {
  for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done
}

function echo_return_code() {
  echo $?
}
