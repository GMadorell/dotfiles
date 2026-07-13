#!/bin/zsh
# File handling, extraction, encryption utilities

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
