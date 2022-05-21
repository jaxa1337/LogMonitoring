#!/bin/bash

cmd_rm="rm -f"
lock_file="/tmp/log_sys_lock_file"

function remove_lock_file() {
    if [ -e "$lock_file" ]; then
        $cmd_rm "$lock_file" || {
            echo "Cannot remove lock file: ${lock_file}"
            exit 3
        }
    fi
}

docker stop promtail nextcloud loki grafana
docker rm promtail nextcloud loki grafana
docker network rm logsystem_network

# docker-compose -f docker-compose.nextcloud.yaml down
# docker-compose down 

remove_lock_file