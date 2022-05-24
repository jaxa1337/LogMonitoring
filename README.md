# LogMonitoring

This simple script automaticly running set of docker containers to logs monitoring in system and nextcloud. 

Containers which will be started: 
- loki
- promtail
- grafana
- nextcloud

## Usage
___

Just use ```start.sh``` file to run containers. When you used this script, lock file was created. This file just block this script, and you must use ```stop.sh``` script to delete lock file. 

In script are some variables. You can change it if you want.
Variables:

    - lock_file="/tmp/log_sys_lock_file" - path to script file
    - loki_config="loki/loki-config.yaml" - path to loki config
    - loki_archive="loki/loki-linux-arm64.zip" - path to loki package
    - promtail_config="promtail/promtail-config.yaml" - path to promtail config
    - promtail_archive="promtail/promtail-linux-amd64.zip" - path to promtail package
    - version=2.5.0 - version of loki and promtail 
    - nextcloud_port=8081 - exposed port of nextcloud container
    - loki_port=3100 - exposed port of loki
    - grafana_port=3000 - exposed port of grafana
    - grafana_username="user"
    - grafana_password="user"
    - grafana_log_level="error"
    - current_directory=$(pwd)
    - logs_directory=$current_directory/logs - path to directory where logs from nextcloud will be stored

Unfortunatelly I cannot use docker-compose, because current version (v1.29.2, 24/04/2022) of it does not support config files. Docker-compose files are ready to use but I cannot use presonalized config files for loki and promtail. 


