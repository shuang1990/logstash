#!/bin/bash
set -e

prj_path=$(cd $(dirname $0); pwd -P)
devops_prj_path="$prj_path/devops"
template_path="$devops_prj_path/template"   
config_path="$devops_prj_path/config"   

logstash_image=logstash:5.4.0
logstash_container=logstash

log_path='/opt/data/logstash'

source $devops_prj_path/base.sh

function run() {
    ensure_dir "$log_path"
    ensure_permissions "$log_path"

    local docker_config_path='/etc/logstash/conf.d'
    local args='--restart=always'
    args="$args --net=host"
    args="$args -v $config_path:$docker_config_path"
    args="$args -v $log_path:/tmp/log"
    
    run_cmd "docker run -d $args --name $logstash_container $logstash_image -f $docker_config_path"
}

function stop() {
    stop_container $logstash_container
}

function restart() {
    stop
    run
}

help() {
cat <<EOF
    Usage: manage.sh [options]

        run
        stop
        restart
EOF
}

ALL_COMMANDS=""
ALL_COMMANDS="$ALL_COMMANDS run stop restart"

list_contains ALL_COMMANDS "$action" || action=help
$action "$@"
