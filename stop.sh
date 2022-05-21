#!/bin/bash

docker stop promtail nextcloud loki grafana
docker rm promtail nextcloud loki grafana
docker network rm logsystem_network
# docker-compose -f docker-compose.nextcloud.yaml down
# docker-compose down 