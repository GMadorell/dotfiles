#!/bin/zsh

# Git module: Git aliases and helper functions
# Consolidates all git-related shell customizations

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
alias gckt="git checkout --theirs"
alias gcko="git checkout --ours"
alias gckmine="git checkout --ours" # Checkout the file I already had (compared to server)
alias gdiscard_unstaged="git checkout -- ."
alias gck_unstaged="git checkout -- ."
alias gckunstaged="git checkout -- ."
# Create (if needed) and checkout a branch built from args joined with "_"
function gckb() {
  if [ $# -eq 0 ]; then
    echo "$LOG_ERROR gckb needs at least one parameter (branch name parts)"
    return 1
  fi

  # Join args with "_" (e.g., gckb feature user auth -> feature_user_auth)
  local raw_name="${(j:_:)@}"

  # Sanitize a bit: lowercase, keep letters/numbers/_/./-//, collapse repeats, trim edges
  local branch_name
  branch_name="$(echo "$raw_name" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9_./-]+/_/g; s/_+/_/g; s|^[_./-]+||; s|[_./-]+$||')"

  if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    echo "$LOG_INFO Branch exists, checking out '$branch_name'..."
    git checkout "$branch_name"
  else
    echo "$LOG_INFO Creating and checking out '$branch_name'..."
    git checkout -b "$branch_name"
  fi
}
function gckl_all() {
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
