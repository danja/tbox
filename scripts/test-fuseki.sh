#!/bin/bash
# test-sparql.sh - Script to test SPARQL UPDATE and SELECT against a Fuseki endpoint

# Configuration
FUSEKI_HOST="http://localhost:4030"
UPDATE_ENDPOINT="${FUSEKI_HOST}/test-mem/update"
QUERY_ENDPOINT="${FUSEKI_HOST}/test-mem/query"
USERNAME="admin"
PASSWORD="admin123"
AUTH_HEADER="Authorization: Basic $(echo -n "${USERNAME}:${PASSWORD}" | base64)"

# Generate a random string (timestamp + random number)
RANDOM_STRING="test-$(date +%s)-$((RANDOM % 1000))"
SUBJECT="<http://example.org/subject/$(date +%s)>"
PREDICATE="<http://example.org/predicate/test>"
OBJECT="\"${RANDOM_STRING}\""

echo "Testing SPARQL endpoint with random string: ${RANDOM_STRING}"

# 1. Create and execute UPDATE query
UPDATE_QUERY="INSERT DATA { ${SUBJECT} ${PREDICATE} ${OBJECT} }"

echo -e "\nSending UPDATE query..."
echo "Attempting to connect to ${UPDATE_ENDPOINT}..."

# Add timeout and verbose output for debugging
curl -v -X POST "${UPDATE_ENDPOINT}" \
  -H "${AUTH_HEADER}" \
  -H "Content-Type: application/sparql-update" \
  --data-binary "${UPDATE_QUERY}" \
  --max-time 10

echo -e "\nUPDATE request completed"

# 2. Create and execute SELECT query to verify the insertion
SELECT_QUERY="SELECT ?s ?p ?o WHERE { ?s ?p \"${RANDOM_STRING}\" }"

echo -e "\nSending SELECT query to verify data..."
# Add timeout here too
curl -v -X POST "${QUERY_ENDPOINT}" \
  -H "${AUTH_HEADER}" \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data-binary "${SELECT_QUERY}" \
  --max-time 10

echo -e "\nTest completed!"