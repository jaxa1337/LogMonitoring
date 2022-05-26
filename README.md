# __LogMonitoring__

This simple script automatically runs set of docker containers to monitor logs in system and nextcloud. 

Containers which will be started: 
- loki
- promtail
- grafana
- nextcloud

__You need only: Docker, wget__

## __Usage__
___

 - Just use ```start.sh``` file to run containers. When you used this script, lock file was created. This file just blocks this script, and you must use ```stop.sh``` script to delete lock file. 

    In script there are some variables. You can change it if you want.
    Variables:
    ```
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
    ```

    Unfortunately I cannot use docker-compose, because current version (v1.29.2, 24/04/2022) of it does not support config files. Docker-compose files are ready to use but I cannot use presonalized config files for loki and promtail.


- Add data source in Grafana (http://0.0.0.0:3000):

    1. Go to: Configuration -> Data Sources -> Add data source -> Loki
    2. Write ```http://loki:3100``` to URL field.
    3. Press ```Save and test``` button.

- Create dashboard in Grafana. Use LogQL to create queries to the Loki.

## Test

If you aren't sure whether logs are collected correctly, you can use cURL. It is the fastest way to make you sure that logs are in Loki. Example:

```
curl -G -s "http://localhost:3100/loki/api/v1/query_range?limit=10" --data-urlencode 'query={job="varlogs"}' | jq
```
----
## __Sources__
- _Promtail_: https://grafana.com/docs/loki/latest/clients/promtail/
- _Grafana_: https://grafana.com/oss/grafana/
- _Loki_: https://grafana.com/oss/loki/
- _LogQL_: https://grafana.com/docs/loki/latest/logql/
- _Nextcloud_: https://hub.docker.com/_/nextcloud/

