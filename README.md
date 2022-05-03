curl -G -s "http://localhost:3100/loki/api/v1/query_range?limit=3" --data-urlencode 'query={job="apache"}' | jq

TODO:
README - uzpełnic
Sieci dockerowe 
docker-compose.yaml
dopracować skrypt uruchomieniowy
dashboard
zapytania przykładowe i co w ogóle zbierać
