docker-compose down --volumes  # Remove containers and volumes
docker-compose build --no-cache  # Rebuild without cache
docker-compose up -d  # Start fresh

docker-compose logs

curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"