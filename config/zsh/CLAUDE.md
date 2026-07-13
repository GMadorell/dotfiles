# Zsh Configuration

```
config/zsh/
├── init.zsh                  # Entry point, sources everything below in order
├── conf.d/                   # Core settings, numeric prefix = load order
│   ├── 01-exports.zsh        # PATH, GOPATH, MANPATH, DOTFILES_PATH, PROJECTS_PATH
│   ├── 02-brew.zsh           # Homebrew shellenv
│   ├── 03-logging.zsh        # LOG_ERROR/LOG_WARNING/LOG_INFO constants
│   ├── 04-localization.zsh   # Locale
│   ├── 05-editor.zsh         # EDITOR/PAGER
│   ├── 06-keybindings.zsh    # bindkey
│   ├── 07-shell-options.zsh  # HISTFILE, shell behavior
│   ├── 08-xdg.zsh            # XDG cache/state dirs
│   └── 09-completion.zsh     # fpath, compinit, zstyle (after oh-my-zsh.sh)
├── modules/
│   ├── language-modes.zsh    # LANG_MODE flags (see languages/)
│   ├── aliases.zsh           # General aliases, clipboard, history, dirs
│   ├── git.zsh                # All git aliases/functions (sole owner — don't duplicate git aliases elsewhere)
│   ├── precmd-hooks.zsh
│   ├── productivity-tools.zsh # zoxide, hstr, broot, direnv, mise
│   ├── shell-final.zsh       # sdkman, bun — must load LAST
│   ├── languages/             # python, ruby, php, js, rust — each conditional on its MODE flag
│   ├── utils/
│   │   ├── string.zsh        # trim, case conversion, uuid
│   │   ├── files.zsh         # extract/encrypt, file listing, search, mail
│   │   ├── hardware.zsh      # battery, cores, benchmark
│   │   ├── network.zsh       # connectivity, weather
│   │   └── formatting.zsh    # JSON, math/units, time/date, notify/timer
│   └── services/              # databases, messaging, docker, datastores, vpn, cloud, tools
│                               # each can be commented out of init.zsh if unused
└── .gitignore
```

Sourcing order lives in `init.zsh` itself — read it, don't duplicate it here.

For conventions on adding modules, testing, and when to split a file, see the
`zsh-config` skill (`.claude/skills/zsh-config/`).
