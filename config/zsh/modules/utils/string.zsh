#!/bin/zsh
# String manipulation utilities

function trim() {
  # Trim specified characters from string (works with pipes or direct arguments)
  # Usage: trim "text" "char" or echo "text" | trim "char"
  if [ $# -eq 1 ]; then
    escaped_input=$(regex_escape "$1")
    while read line; do
      echo "$line" | sed "s~^$escaped_input*~~; s~$escaped_input*\$~~"
    done
  elif [ $# -eq 2 ]; then
    echo "$2" | trim "$1"
  fi
}

function ltrim() {
  if [ $# -eq 1 ]; then
    escaped_input=$(regex_escape "$1")
    while read line; do
      echo "$line" | sed "s~^$escaped_input*~~"
    done
  elif [ $# -eq 2 ]; then
    echo "$1" | ltrim "$2"
  else
    echo "$LOG_ERROR ltrim needs either two args or a single arg (will trim stdin)"
  fi
}

function regex_escape() {
  python -c "import re; print(re.escape('$1'))"
}

# Case conversion
function title2kebab() { case_converter -f title -t kebab "$1"; }
function kebab2title() { case_converter -f kebab -t title "$1"; }
