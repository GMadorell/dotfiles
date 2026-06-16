if [[ -s $HOME/.secrets ]] ; then source $HOME/.secrets ; fi
export PYTHONPATH="$PYTHONPATH:$HOME/.python_dev_links"
export PATH="$PATH:$HOME/.python_dev_links"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
. "$HOME/.cargo/env"
export AWS_PROFILE=saml

# peon-ping quick controls
alias peon="bash /Users/gerard/.claude/hooks/peon-ping/peon.sh"
[ -f /Users/gerard/.claude/hooks/peon-ping/completions.bash ] && source /Users/gerard/.claude/hooks/peon-ping/completions.bash

alias claude-mem='/Users/gerard/.bun/bin/bun "/Users/gerard/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
