# Dotfiles

Hello! Welcome to where I store my configuration files!

## How to import the files

1. Clone the repo: `git clone git@github.com:GMadorell/dotfiles.git ~/.dotfiles`
2. Install [RCM](https://github.com/thoughtbot/rcm): `brew tap thoughtbot/formulae && brew install rcm`
3. Check what symlinks are going to be created: `lsrc`
4. Create the symlinks: `rcup`

To track a new file/dir, move it into this repo and symlink it back with `mkrc $PATH` (add `-S` to
symlink a directory as a whole instead of file-by-file, `-U` to link it undotted, e.g. `bin` -> `~/bin`
per `UNDOTTED` in `rcrc`), then re-run `rcup`. `EXCLUDES` in `rcrc` lists paths `rcup` should skip.

Some configuration files need extra work though!

### Brew
Execute `brew bundle install Brewfile`, or `brew bundle dump` for exporting.

### Better touch tool
Import inside the program (click on manage presets for exporting / importing).

### Iterm2
Thanks to: http://stratus3d.com/blog/2015/02/28/sync-iterm2-profile-with-dotfiles-repository/
```
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```

### Cronjobs
Scripts meant to run on a schedule live in `bin/cronjobs/`, symlinked undotted into `~/bin/cronjobs/`
(see `UNDOTTED` above).

`rcup` only creates the symlinks — it does **not** install anything into crontab. After adding a new
script here, wire it up manually:

```
crontab -e
```

Each entry points at the symlinked path in `~/bin/cronjobs/` (not the dotfiles path directly) and logs
to the same shared files, e.g.:

```
0 * * * * /Users/gmadorell/bin/cronjobs/brew_maintenance >>/tmp/crontab_stdout.log 2>>/tmp/crontab_stderr.log
```

The crontab itself isn't tracked in this repo, only the scripts are.
