echo -e "\nDeleting data from ..."
curl -X POST http://localhost:4030/test-mem \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data "DELETE * WHERE { ?s ?p ?o }"
