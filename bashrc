if [[ -s $HOME/.secrets ]] ; then source $HOME/.secrets ; fi
export PYTHONPATH="$PYTHONPATH:$HOME/.python_dev_links"
export PATH="$PATH:$HOME/.python_dev_links"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

