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
`~/.zshrc` forwards to `config/zsh/init.zsh`, which is synced as a single directory to
`~/.config/zsh/` via `SYMLINK_DIRS`. See `config/zsh/CLAUDE.md` for its structure.

After running `rcup`, test with: `zsh -i -c "echo OK"` (should not error)

### Brew
Execute `brew bundle install Brewfile`, or `brew bundle dump` for exporting.

### Better touch tool
Import inside the program (click on manage presets for exporting / importing).

#### Fixing a shortcut macOS steals (e.g. wezterm's Cmd+Ctrl+D)

**Problem:** macOS sometimes hijacks a shortcut before the app ever sees it.
Example: `Cmd+Ctrl+D` = "Look Up in Dictionary". Turning that off in System
Settings does NOT fix it — it's a different, hidden setting. No app can win
against this.

**Fix:** use BTT to grab the shortcut first, then redirect it to a free one.

Steps:
1. BTT Preferences → Keyboard
2. Scope it to one app only (e.g. WezTerm), so nothing else breaks
3. New Shortcut → record the stolen combo (e.g. `Cmd+Ctrl+D`)
4. Action → "Keyboard Shortcuts" → "Send Keyboard Shortcut" → pick a free combo (e.g. `Cmd+Ctrl+9`)
5. Bind the app to that free combo instead

Example already set up: `Cmd+Ctrl+D` → `Cmd+Ctrl+9` for wezterm (pane move
right), config in `config/wezterm/wezterm.lua`.

⚠️ After adding a rule like this, re-export the BTT preset
(`better-touch-tool/Skabed.bttpreset`) or it's lost from this repo.

### Iterm2
Thanks to: http://stratus3d.com/blog/2015/02/28/sync-iterm2-profile-with-dotfiles-repository/
```
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/.dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```

### Video defaults
Run `bin/macos_video_defaults` once.

### IINA
Key bindings: `Library/Application Support/com.colliderli.iina/input_conf/` (synced via `rcup`).
Playback prefs: run `bin/iina_defaults`.

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

### Wake scripts
Scripts to run on wake-from-sleep live in `bin/wake/` (mirrors `bin/cronjobs/`), dispatched from the
tracked `~/.wakeup` via [sleepwatcher](https://formulae.brew.sh/formula/sleepwatcher).

- Install: `brew bundle install Brewfile && brew services start sleepwatcher`
