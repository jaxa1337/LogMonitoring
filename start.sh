#!/bin/bash

## In case of any error without piplelining - exit immediately
# set -e

## Exit if tere is unbound (unused) variables
# set -u

## Redirect all error output to errors.log
exec 6>&2
exec 2>errors.log

## Varibles
cmd_rm="rm -f"
lock_file="/tmp/log_sys_lock_file"
loki_config="loki/loki-config.yaml"
loki_archive="loki/loki-linux-arm64.zip"
promtail_config="promtail/promtail-config.yaml"
promtail_archive="promtail/promtail-linux-amd64.zip"
version=2.5.0
nextcloud_port=8081
loki_port=3100
grafana_port=3000
grafana_username="user"
grafana_password="user"
grafana_log_level="error"
current_directory=$(pwd)
logs_directory=$current_directory/logs

## Links
link_loki_config="https://raw.githubusercontent.com/grafana/loki/v$version/cmd/loki/loki-local-config.yaml"
link_loki_archive="https://github.com/grafana/loki/releases/download/v$version/loki-linux-arm64.zip"
link_promtail_config="https://raw.githubusercontent.com/grafana/loki/v$version/clients/cmd/promtail/promtail-docker-config.yaml"
link_promtail_archive="https://github.com/grafana/loki/releases/download/v$version/promtail-linux-amd64.zip"

## Check directory and if doesn't exist, create this.
function test_create_directory() {
    if [ -d "$1" ]; then
        echo "$1 directory exist!"
    else
        mkdir "$1"
        echo "$1 directory created."
    fi
}

## Check if lock_file exist and delete it if is.
function remove_lock_file() {
    if [ -e "$lock_file" ]; then
        $cmd_rm "$lock_file" || {
            echo "Cannot remove lock file: ${lock_file}"
            exit 3
        }
        echo "Lock file removed."
    fi
}

## Check if file exist, if not download them.
function check_download_file() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        if [ ! -e "$1" ]; then
            echo "Try download file $1 from $2"
            wget "$2" -O "$1"
        else
            echo "File $1 exist!"
            return 2
        fi
    else
        echo "This function needs two arguments!"
        exit 2
    fi

    if [ -s "$1" ]; then
        echo "File downloaded. OK."
        return 1
    else
        echo "Download failed!"
        $cmd_rm "$1"
    fi
}

if [ -e "$lock_file" ]; then
    echo "Lock file exist. Cannot run this script. You must run stop.sh script"
    exit 1
fi


## Catch Ctr+C signal
trap remove_lock_file SIGINT

## Create directories for loki promtail grafana and logs
directories=(grafana logs loki promtail)
for directory in "${directories[@]}"; do
    test_create_directory "$directory"
done

##Download nessesary files
check_download_file $loki_config $link_loki_config
check_download_file $loki_archive $link_loki_archive
check_download_file $promtail_config $link_promtail_config
check_download_file $promtail_archive $link_promtail_archive

echo "Logs from nextcloud will be stored in $logs_directory."

#Edit config files
if [ -z "$(grep "host_log" ./$promtail_config)" ]; then
    sed -i 's/var\/log/var\/log\/host_log/' $promtail_config
fi

text="- job_name: nextcloud
  static_configs:
  - targets:
      - localhost
    labels:
      job: nextcloud_apache
      __path__: /var/nextcloud/*log"

if [ -z "$(grep "nextcloud" ./$promtail_config)" ]; then
    echo "$text" >> $promtail_config
fi


#------------------------RUN DOCKER CONTAINERS---------------------------------
exec 2>&6
# docker-compose -f docker-compose.nextcloud.yaml up -d
# docker-compose up -d
touch $lock_file
docker network create logsystem_network

# -----------NEXTCLOUD---------
# -v path_on_host:path_in_docker_container \
echo "Starting nextcloud container..."
docker run --name nextcloud -d \
        --restart=always \
        -p $nextcloud_port:80 \
        -v "$logs_directory":/var/log/apache2 \
        --network logsystem_network \
        nextcloud

#--------------LOKI-----------
echo "Starting loki container..."
docker run --name loki -d \
        -v "$current_directory"/loki:/mnt/config \
        --restart=always \
        --network logsystem_network \
        -p $loki_port:3100 grafana/loki:$version \
        -config.file=/mnt/config/loki-config.yaml


#------------PROMTAIL---------
echo "Starting promtail container..."
docker run --name promtail -d \
        --restart=always \
        -v "$current_directory"/promtail:/mnt/config \
        -v /var/log:/var/log/host_log \
        -v "$logs_directory":/var/nextcloud \
        --network logsystem_network \
        --link loki grafana/promtail:$version \
        -config.file=/mnt/config/promtail-config.yaml

#------------GRAFANA-----------
echo "Starting grafana container..."
docker run --name grafana -d \
        --restart=always \
        -p $grafana_port:3000 \
        -e "GF_SECURITY_ADMIN_USER=$grafana_username" \
        -e "GF_SECURITY_ADMIN_PASSWORD=$grafana_password" \
        -e "GF_LOG_LEVEL=$grafana_log_level" \
        --network logsystem_network \
        grafana/grafana
