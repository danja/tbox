echo -e "\nDeleting data from ..."
curl -X POST http://localhost:4030/test-mem/update \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  -H "Accept: application/sparql-results+json" \
  --data "DELETE { ?s ?p ?o} WHERE { ?s ?p ?o }"
