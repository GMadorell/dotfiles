#!/bin/zsh
# Weather related

function weather() { curl wttr.in/$1 ; }
function weatherbcn() { weather barcelona ; }

ropa() { # usage: ropa "some city"
    query="$*"
    modified_query="${query// /-}"
    url="https://puedotenderlaropa.com/$modified_query"
    if command -v xdg-open > /dev/null; then
        xdg-open "$url"
    elif command -v open > /dev/null; then
        open "$url"
    else
        echo "Cannot detect a method to open URLs on this system."
    fi
}
