# docker-compose down --volumes  # Remove containers and volumes

docker-compose down
docker-compose build --no-cache  # Rebuild without cache
docker-compose up -d  # Start fresh

docker-compose logs

curl -X GET http://localhost:4030/test-mem/query \
  -H "Accept: application/sparql-results+json" \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"