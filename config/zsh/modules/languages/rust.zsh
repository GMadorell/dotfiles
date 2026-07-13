#!/bin/zsh
# Rust setup (cargo, rustup)
# Depends: modules/language-modes.zsh (for RUST_MODE flag)

# Rust aliases
alias cb="cargo test --no-run --color always 2>&1 | less -r"
alias ct="cargo test"
function cto() { "cargo test --test $1"; }
alias cj="cargo build && cargo fmt --all && cargo clippy --fix --all-targets --allow-dirty --allow-staged && cargo clippy --all-targets -- -D warnings"

function setup_rust() {
  export CARGO_TARGET_DIR="$HOME/.cargo/cargo_global_target_dir"
  if [ ! -d "$CARGO_TARGET_DIR" ]; then
    mkdir -p "$CARGO_TARGET_DIR"
  fi
}

alias toggle_rust="setup_rust"
alias enable_rust="setup_rust"
alias rust_enable=enable_rust

if (($RUST_MODE)); then
  setup_rust
fi
