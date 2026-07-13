#!/bin/zsh
# JSON and math/unit formatting utilities

# JSON
alias compress_json="jq -c"
alias json_compress=compress_json

# Math / units
function convert_units() {
  local help="Eg: convert_units 3600 seconds hours"
  units "$1 $2" $3
}
alias unit_conversion=convert_units

function remove_decimals () { echo ${1%.*} ; }
