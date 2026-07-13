#!/bin/zsh
# Database service aliases: MySQL, PostgreSQL, InfluxDB

## MySQL
alias mycli="mycli"
alias myinit="brew services run mysql@5.7"
alias mystop="brew services stop mysql@5.7"
alias myrestart="brew services restart mysql@5.7"
alias mycheck="mysql.server status"
alias myversion="mysql --version"
alias mycnf="$EDITOR /usr/local/etc/my.cnf"

## PostgreSQL
alias pgcli='pgcli'
alias pginit="brew services run postgresql"
alias pgstop="brew services stop postgresql"
alias pgrestart="brew services restart postgresql"

## InfluxDB
alias influxdbcli="influx"
function influxdbinit() { brew services run influxdb ; }
function influxdbstop() { brew services stop influxdb ; }
function influxdbrestart() { brew services restart influxdb ; }
# --- replicate influxdb aliases as influx
alias influxcli="influxdbcli"
function influxinit() { influxdbinit ; }
function influxstop() { influxdbstop ; }
function influxrestart() { influxdbrestart ; }
