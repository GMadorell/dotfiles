#!/bin/zsh
# Tool service aliases: Apache, Grafana

# Apache
function apacherestart() { sudo apachectl restart ; }

# Grafana
function grafanainit() { brew services run grafana ; }
function grafanastop() { brew services stop grafana ; }
function grafanarestart() { brew services restart grafana ; }
function grafanaport() { ports | sed -n -e '1p;/grafana/p' ; }
