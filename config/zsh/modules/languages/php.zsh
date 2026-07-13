#!/bin/zsh
# PHP setup
# Depends: modules/language-modes.zsh (for PHP_MODE flag)

function setup_php() {
  DEFAULT_PHP_VERSION="7"

  function php_find_ini() { php --ini ; }
  function phpunit { bin/phpunit ; }
  function phpunit_filter { bin/phpunit --filter $1 ; }
  function phpunitfilter { phpunit_filter ; }
  function behat { bin/behat ; }
  function fix_php_changed_files { gchanged_files | grep .php | xargs phpcbf --standard=PSR2 ; }
}

alias toggle_php="setup_php"
alias enable_php="setup_php"
alias php_enable=enable_php

if (($PHP_MODE)) ; then
  setup_php
fi
