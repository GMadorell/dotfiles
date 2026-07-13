# Dotfiles

Hello! Welcome to where I store my configuration files!

## How to import the files

1. Clone the repo: `git clone git@github.com:GMadorell/dotfiles.git ~/.dotfiles`
2. Install [RCM](https://github.com/thoughtbot/rcm): `brew tap thoughtbot/formulae && brew install rcm`
3. Check what symlinks are going to be created: `lsrc`
4. Create the symlinks: `rcup`

To track a new file/dir, move it into this repo and symlink it back with `mkrc $PATH` (add `-U` to
link it undotted, e.g. `bin` -> `~/bin` per `UNDOTTED` in `rcrc`), then re-run `rcup`. `EXCLUDES` in
`rcrc` lists paths `rcup` should skip.

By default `rcup` mirrors a directory's structure and symlinks each file individually (so new files
added on either side need a re-run of `rcup` to pick up). To make an entire directory sync as a single
symlink instead — new files added on either side show up immediately, no re-run needed — add its name
to `SYMLINK_DIRS` in `rcrc` (e.g. `config/nvim`, see `nvim` entry).

Some configuration files need extra work though!

### Zsh
The zsh configuration is modular and synced as a single directory via RCM's `SYMLINK_DIRS`:
- `~/.zshrc` (at repo root) forwards to the modular config
- `~/.config/zsh/` (via `SYMLINK_DIRS`) contains the modular structure:
  - `conf.d/`: core settings (exports, keybindings, completion, etc.)
  - `modules/`: features (aliases, git, languages, utilities, services)
  - `init.zsh`: entry point that sources everything in order

After running `rcup`, test with: `zsh -i -c "echo OK"` (should not error)

For maintainers: See `config/zsh/CLAUDE.md` for structure, conventions, and how to add new modules.

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

The actual schedule is kept in the `crontab` file at the repo root (excluded from `rcup`, since crontab
isn't something you symlink into) — entries point at `~/bin/cronjobs/*`, e.g.:
```
0 * * * * /Users/gmadorell/bin/cronjobs/brew_maintenance >>/tmp/crontab_stdout.log 2>>/tmp/crontab_stderr.log
```

- Install it: `crontab crontab`
- Edit it: `crontab -e`, then back up with `crontab -l > crontab`
