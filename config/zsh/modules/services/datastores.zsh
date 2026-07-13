#!/bin/zsh
# Datastore service aliases: Redis, Elasticsearch

# Redis aliases
alias rediscli="redis-cli"
function redisinit() { brew services run redis ; }
function redisstop() { brew services stop redis ; }
function redisrestart() { brew services restart redis ; }
function redischeck() { redis-cli ping ; }
function redisport() { ports | sed -n -e '1p;/redis/p' ; }

# Elasticsearch
elasticsearch_version="elasticsearch@5.6"
function esinit() { brew services run $elasticsearch_version ; }
function esstop() { brew services stop $elasticsearch_version ; }
function esrestart() { brew services restart $elasticsearch_version ; }
function esport() {
  es_status=$(get http://localhost:9200/_cluster/health | jq -r '{message: .status} | "\(.message)"')
  if [[ "$es_status" == "green" ]]; then
    echo "9200"
  else
    echo "$LOG_ERROR elastic search seems to not be running on port 9200 (or it might be just starting, try again?)"
  fi
}
function escheck() {
  es_status=$(get http://localhost:9200/_cluster/health | jq -r '{message: .status} | "\(.message)"')
  if [[ "$es_status" == "green" ]]; then
    echo "Status: OK"
  else
    echo "$LOG_ERROR elastic search seems to not be running on port 9200 (or it might be just starting, try again?)"
  fi
}
function escnf() { $EDITOR /usr/local/etc/elasticsearch/elasticsearch.yml ; }
function esplugin() { /usr/local/opt/elasticsearch@5.6/libexec/bin/elasticsearch-plugin $@ ; }
