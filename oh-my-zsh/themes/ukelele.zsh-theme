# AVIT ZSH Theme

PROMPT='
$(_user_host)$(_current_dir) $(git_prompt_info)
%{$fg[$CARETCOLOR]%}▶%{$resetcolor%} '

local _return_status="%{$fg[red]%}%(?..⍉)%{$reset_color%}"
local _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

function _current_dir() {
  # http://stackoverflow.com/questions/30962925/collapse-directories-in-zsh-prompt
  local _collapsed_pwd=$(pwd | perl -pe "s|^$HOME|~|g; s|/([^/])[^/]*(?=/[^/]*/[^/]*/)|/\$1|g")
  echo "%{$fg[magenta]%}$_collapsed_pwd%{$reset_color%}"
}

function _user_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[cyan]%}$me%{$reset_color%}:"
  fi
}

function _vi_status() {
  if {echo $fpath | grep -q "plugins/vi-mode"}; then
    echo "$(vi_mode_prompt_info)"
  fi
}

if [[ $USER == "root" ]]; then
  CARETCOLOR="red"
else
  CARETCOLOR="white"
fi

MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑ "
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖ "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§ "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}◒ "

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

# LS colors, made with http://geoff.greer.fm/lscolors/
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export GREP_COLOR='1;33'
