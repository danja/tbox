# Add test data
curl -X POST http://localhost:4030/ds/update \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  --data "INSERT DATA { <http://example/s> <http://example/p> <http://example/o> }"

# Restart containers
docker-compose restart

# Query to verify data remains
curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"