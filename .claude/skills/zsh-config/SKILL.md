---
name: zsh-config
description: Use when adding, splitting, or reorganizing files under config/zsh/ — conventions, testing, and module-split guidance.
---

See `config/zsh/CLAUDE.md` for the directory layout first.

## Module conventions

- Shebang `#!/bin/zsh` on every file.
- One-line header comment describing scope. Add a `# Depends: <file> (for <thing>)` line only when load order actually matters (silent breakage if reordered) — don't narrate obvious things like numeric-prefix ordering.
- Guard clauses for expensive/idempotent setup, e.g.:
  ```zsh
  [[ -n "$PYTHON_SETUP_DONE" ]] && return 0
  command -v pyenv &>/dev/null && { eval "$(pyenv init -)"; PYTHON_SETUP_DONE=1; }
  ```

## Language modules (`modules/languages/`)

Each defines `setup_LANG()`, is gated by a `LANG_MODE` flag from `language-modes.zsh`, and exposes `toggle_LANG`/`enable_LANG` aliases. `LANG_MODE=0` means the function is defined but not auto-invoked (deferred, not lazy — it's still parsed at startup).

## Service modules (`modules/services/`)

Naming: `ABBREVinit`, `ABBREVstop`, `ABBREVrestart`, `ABBREVcheck`, `ABBREVcli`, `ABBREVport`. Comment out the `source` line in `init.zsh` to disable a whole category — there's no runtime `command -v` gating.

## Adding a module

1. Create the file in the right directory (`languages/`, `services/`, or `utils/`).
2. Add its `source` line to `init.zsh` in the right position (sourcing is fully explicit — no globbing).
3. Before adding new content, check whether it already exists somewhere else (`grep -rn "your_function_name" config/zsh/`) — duplication across modules has bitten this config before.

## When to split a module

- File exceeds ~200 lines and has a natural seam (e.g. `git.zsh` growing past `git-core.zsh` / `git-branch.zsh`).
- A subset is rarely used and should be independently toggle-able.
- Don't split along lines that create circular or unclear dependencies — if A always needs B, merge them.

## Testing a change

```bash
zsh -n config/zsh/<file>.zsh                 # syntax check
zsh -i -c "source config/zsh/init.zsh; exit"  # loads without error
time zsh -i -c exit                           # startup regression check (<5% vs baseline)
alias | grep <name>; type <function_name>     # confirm it's defined
```
