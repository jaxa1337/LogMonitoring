curl -G -s "http://localhost:3100/loki/api/v1/query_range?limit=3" --data-urlencode 'query={job="apache"}' | jq

TODO:
README - uzpełnic
logi grafana
dopracować skrypt uruchomieniowy
dashboard
zapytania przykładowe i co w ogóle zbierać
configs in docker-compose are a fiction, doesnt work

