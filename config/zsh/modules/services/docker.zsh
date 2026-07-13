#!/bin/zsh
# Docker service aliases: Docker, Docker-Compose

# Docker aliases
alias docker_list_active_containers="docker container list"
alias docker_list_stopped_containers="docker ps --filter \"status=exited\""
alias docker_list_all_containers="docker ps -a"
alias docker_list_images="docker image list"
alias docker_start_container="docker container start"
function docker_connect() {
  container=$(docker ps | awk '{if (NR!=1) print $1 ": " $(NF)}' | percol --prompt='<green>Select the container:</green> %q')
  container_id=$(echo $container | awk -F ': ' '{print $1}')
  docker exec -i -t $container_id /bin/bash
}
function docker_stop_all() {
  docker stop $(docker ps -a -q)
}
alias dockerstopall=docker_stop_all

function dps() {
  docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" \
     | awk 'NR == 1; NR > 1 { print $0 | "sort" }';
}
alias dls="dps"
function dpsg() {
  dps | grep $1
}

# Docker-Compose aliases
alias docker-compose-restart="docker-compose rm -s -f && docker-compose up -d"
alias docker_compose_restart=docker-compose-restart
