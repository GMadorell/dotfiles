# Zsh Configuration Developer Guide

## Directory Layout

```
config/zsh/
├── init.zsh                  # Main entry point, sources all modules in order
├── conf.d/                   # Configuration snippets (sourced first, numeric order)
│   ├── 01-exports.zsh        # PATH, GOPATH, MANPATH, DOTFILES_PATH, PROJECTS_PATH
│   ├── 02-brew.zsh           # Homebrew environment setup
│   ├── 03-logging.zsh        # LOG_ERROR, LOG_WARNING, LOG_INFO constants
│   ├── 04-localization.zsh   # Locale and character encoding (LC_ALL, LANG)
│   ├── 05-editor.zsh         # EDITOR and PAGER configuration
│   ├── 06-keybindings.zsh    # Keybindings (Ctrl+A, Ctrl+S, etc.) and KEYTIMEOUT
│   ├── 07-shell-options.zsh  # Shell behavior (expandable for HIST*, COMP* options)
│   ├── 08-xdg.zsh            # XDG Base Directory paths for caches and state
│   └── 09-completion.zsh     # fpath, compinit, zstyle rules, bracketed-paste fix
├── modules/                  # Modular feature groups
│   ├── language-modes.zsh    # MODE flags for selective language initialization
│   ├── aliases.zsh           # Basic aliases (ls colors, shortcuts, etc.)
│   ├── git.zsh               # Git functions and aliases
│   ├── precmd-hooks.zsh      # Precmd functions (window title, prompts)
│   ├── productivity-tools.zsh # zoxide, hstr, broot, direnv, mise
│   ├── shell-final.zsh       # sdkman, bun (must run last)
│   ├── languages/            # Language-specific setup (conditional on MODE flags)
│   │   ├── python.zsh
│   │   ├── ruby.zsh
│   │   ├── js.zsh
│   │   ├── php.zsh
│   │   └── rust.zsh
│   ├── utils/                # Utility functions organized by category
│   │   ├── string.zsh        # String manipulation (trim, case conversion, etc.)
│   │   ├── files.zsh         # File operations, search, browser functions
│   │   ├── hardware.zsh      # Hardware info (battery, CPU, ports, load)
│   │   └── formatting.zsh    # JSON, regex, math, time/date functions
│   └── services/             # Service management (optional, can be commented out)
│       ├── databases.zsh     # MySQL, PostgreSQL, InfluxDB
│       ├── messaging.zsh     # Kafka, RabbitMQ, Zookeeper
│       ├── docker.zsh        # Docker and Docker Compose
│       ├── datastores.zsh    # Redis, Elasticsearch
│       ├── vpn.zsh           # Pritunl and VPN functions
│       ├── cloud.zsh         # AWS setup
│       └── tools.zsh         # Apache, Grafana, misc tools
└── .gitignore                # Exclude caches and history
```

## Sourcing Order in init.zsh

The initialization follows a strict order to ensure dependencies are met. See init.zsh for the actual source statements.

Current order:
1. **conf.d/** (numeric prefixes 01-09, automatically sourced in order)
2. **modules/language-modes.zsh** (sets MODE flags for languages)
3. **modules/aliases.zsh** (basic aliases)
4. **modules/git.zsh** (git functions and aliases)
5. **modules/precmd-hooks.zsh** (shell hook functions)
6. **modules/productivity-tools.zsh** (zoxide, hstr, broot, direnv, mise)
7. **modules/languages/** (language-specific setup, conditional on MODE)
8. **modules/utils/** (utility functions by category)
9. **modules/services/** (optional service aliases and functions)
10. **modules/shell-final.zsh** (must be last: sdkman, bun)

## Module Conventions

### Every Module Must Have
- **Shebang**: `#!/bin/zsh` (for syntax highlighting and identification)
- **Header comment**: Describes what the module does and its dependencies

Example:
```zsh
#!/bin/zsh
# python.zsh — Python environment setup
# Depends on: conf.d/paths (DOTFILES_PATH, PATH setup)
# Provides: setup_python(), aliases for Python

# ... module code ...
```

### Optional but Recommended
- **Guard clauses**: Skip expensive setup if already initialized
- **Error handling**: Check for command availability before using them

Example:
```zsh
# Guard: only run once
[[ -n "$PYTHON_SETUP_DONE" ]] && return 0

# Check availability
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
  PYTHON_SETUP_DONE=1
fi
```

## Language Modules

Located in `modules/languages/`. Each language module:

1. **Checks MODE flag**: `LANG_MODE` variable controls whether to load
   - Set in `.zshrc`: `PYTHON_MODE=1`, `RUBY_MODE=0`, etc.
   - Example: `if (( PYTHON_MODE )); then setup_python; fi`

2. **Defines a setup function**: `setup_LANG()`
   - Initializes language runtime (pyenv, rbenv, nvm, etc.)
   - Sets language-specific environment variables
   - Example: `setup_python()`, `setup_ruby()`, `setup_js()`

3. **Provides mode toggle aliases**:
   - `toggle_LANG`: Toggle the setup on/off
   - `enable_LANG`: Ensure setup is enabled
   - Aliases for common operations (e.g., `cb`, `ct` for Cargo)

### Example Language Module Structure
```zsh
#!/bin/zsh
# ruby.zsh — Ruby environment setup
# Depends on: conf.d/paths
# Provides: setup_ruby(), toggle_ruby

function setup_ruby() {
  eval "$(rbenv init -)"
}

alias toggle_ruby="setup_ruby"
alias enable_ruby="setup_ruby"
alias ruby_enable=enable_ruby
alias activate_ruby="setup_ruby"

# Auto-load if mode flag is set
if (( RUBY_MODE )); then
  setup_ruby
fi
```

## Service Modules

Located in `modules/services/`. Each service module provides aliases and functions for service management.

Naming convention: Use short abbreviations + operation (e.g., `myinit` for MySQL init, `pgstop` for PostgreSQL stop, `rediscli` for Redis CLI).

Common operations:
- **init**: `ABBREV+init` or `ABBREVinit` — Start the service (e.g., `myinit`, `redisinit`)
- **stop**: `ABBREVstop` — Stop the service (e.g., `mystop`, `redisstop`)
- **restart**: `ABBREVrestart` — Restart the service
- **check**: `ABBREVcheck` — Check service status
- **cli**: `ABBREVcli` — Open CLI interface (e.g., `rediscli`)
- **port**: `ABBREVport` — Show listening port

Example abbreviations: `my` (MySQL), `pg` (PostgreSQL), `redis`, `elastic`/`es` (Elasticsearch), `kafka`, `rabbit` (RabbitMQ), `docker`/`d`, `k8s`

### Example Service Module
```zsh
#!/bin/zsh
# redis.zsh — Redis service management
# Provides: redisinit, redisstop, redisrestart, redischeck, rediscli

alias rediscli="redis-cli"

function redisinit() { 
  brew services run redis 
}

function redisstop() { 
  brew services stop redis 
}

function redisrestart() { 
  brew services restart redis 
}

function redischeck() { 
  redis-cli ping 
}

function redisport() { 
  ports | sed -n -e '1p;/redis/p' 
}
```

### Service Modules Can Be Commented Out
Service modules can be disabled by commenting them out in `init.zsh` if not needed:
```zsh
# source modules/services/elasticsearch.zsh  # Not using ES currently
source modules/services/redis.zsh
source modules/services/postgresql.zsh
```

## Utility Modules

Located in `modules/utils/`. Include:
- **git.zsh**: Git aliases and helper functions
- **docker.zsh**: Docker/container functions
- **k8s.zsh**: Kubernetes aliases
- **file.zsh**: File operations (extract, encrypt, search)
- **string.zsh**: String manipulation helpers
- **network.zsh**: Internet/connectivity functions

Utility modules are typically independent and can be sourced in any order.

## Adding New Modules

### When to Create a Module
- Clearly separate concern (e.g., a new language, service, or utility group)
- Can be toggled on/off independently
- Functions/aliases logically grouped

### How to Wire It In

1. **Create the module file** in the appropriate directory:
   ```bash
   # For a new language
   touch config/zsh/modules/languages/go.zsh
   
   # For a new service
   touch config/zsh/modules/services/rabbitmq.zsh
   
   # For a new utility group
   touch config/zsh/modules/utils/http.zsh
   ```

2. **Add it to init.zsh**:
   ```zsh
   # For languages (in language section)
   source modules/languages/go.zsh
   
   # For services (in service section)
   source modules/services/rabbitmq.zsh
   
   # For utils (in utils section)
   source modules/utils/http.zsh
   ```

3. **Write the module** with shebang, header comment, and implementation
4. **Test the module** (see Testing section below)

## Testing

### Startup Timing
Check that sourcing is efficient:
```bash
# Time a full shell startup
time zsh -i -c exit

# With profiling (add to init.zsh temporarily)
setopt XTRACE
PS4='[%U%D{%H:%M:%S.%.}] %x:%I> '
```

### Smoke Tests
Verify basic functionality:
```bash
# Check that aliases are available
alias | grep redis
alias | grep python

# Check that functions are defined
type setup_python
type redisinit

# Run setup functions directly
setup_python
setup_ruby

# Check that MODE flags work
PYTHON_MODE=0 zsh -i -c "type setup_python" && echo "ERROR: should not be loaded"
PYTHON_MODE=1 zsh -i -c "type setup_python" && echo "OK: loaded with mode"
```

### Feature Tests
Test specific functionality in modules:
```bash
# Test git aliases
git_branch_name
gbname
gcurrent_branch_name

# Test docker functions
docker_list_active_containers
dps

# Test utility functions
randomuuid
mkcdir /tmp/test123
```

### Integration Testing
Load a minimal config and verify sourcing order:
```zsh
#!/bin/zsh
# test-init.zsh

# Minimal conf.d
mkdir -p test_config/conf.d test_config/modules/languages test_config/modules/utils test_config/modules/services test_config/modules/shell-final

# Simple test files
cat > test_config/conf.d/00-test.zsh <<EOF
export TEST_CONF_LOADED=1
EOF

# Source and verify
source test_config/conf.d/*.zsh
echo "TEST_CONF_LOADED=$TEST_CONF_LOADED"  # Should be 1
```

## When to Split Modules

Split a module when:

1. **File size exceeds 200 lines**: Harder to navigate and maintain
   - Group related functions into a separate file
   - Example: `git.zsh` getting too large? Split into `git.zsh` and `git-advanced.zsh`

2. **Rarely used features**: Keep optional things isolated
   - Example: `elasticsearch.zsh` is not needed by everyone; keep separate so it can be commented out

3. **No inter-module dependencies**: Modules should be independently sourceable
   - If module A always depends on module B, consider merging them

### Example: Splitting a Large Module

Before (git.zsh is 400+ lines):
```zsh
# All git aliases and functions in one file
```

After (split into focused modules):
```
modules/utils/
├── git-core.zsh       # Basic aliases (gp, gs, gc, etc.)
├── git-branch.zsh     # Branch management (gckb, gbname, etc.)
├── git-advanced.zsh   # Cherry-pick, rebase, integration tools
└── git-machete.zsh    # Git machete specific (rarely used, can be commented)
```

Update `init.zsh`:
```zsh
source modules/utils/git-core.zsh
source modules/utils/git-branch.zsh
source modules/utils/git-advanced.zsh
# source modules/utils/git-machete.zsh  # Optional: uncomment if needed
```

## Best Practices

1. **Minimize startup impact**: Lazy-load expensive operations when possible
2. **Use guard clauses**: Avoid re-sourcing or double-initialization
3. **Group logically**: Keep related functions together
4. **Clear dependencies**: Document what each module needs in header comments
5. **Test in isolation**: Verify modules work independently
6. **Use consistent naming**: Follow the service abbrev pattern (e.g., `SERVICE+init`)
7. **Prefer functions over aliases for complex operations**: Easier to debug and maintain
8. **Add comments for non-obvious code**: Especially workarounds or hacks
