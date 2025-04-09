#!/bin/bash
# fuseki-test.sh - Script to test Fuseki endpoint connectivity

FUSEKI_HOST=${1:-localhost}
FUSEKI_PORT=${2:-4030}
FUSEKI_DATASET=${3:-semem}
BASE_URL="http://${FUSEKI_HOST}:${FUSEKI_PORT}"

echo "Testing Fuseki connection at ${BASE_URL}..."

# Test 1: Server Info
echo "Test 1: Server info endpoint"
curl -s -o /dev/null -w "Server ping status: %{http_code}\n" "${BASE_URL}/$/ping"

# Test 2: Dataset exists
echo "Test 2: Dataset exists"
curl -s -o /dev/null -w "Dataset status: %{http_code}\n" "${BASE_URL}/${FUSEKI_DATASET}"

# Test 3: Simple SPARQL query
echo "Test 3: Simple SPARQL query"
QUERY="SELECT * WHERE { ?s ?p ?o } LIMIT 10"
ENCODED_QUERY=$(echo $QUERY | sed 's/ /%20/g')

curl -s -H "Accept: application/sparql-results+json" \
  -o /dev/null -w "Query status: %{http_code}\n" \
  "${BASE_URL}/${FUSEKI_DATASET}/query?query=${ENCODED_QUERY}"

# Test 4: Post a SPARQL query
echo "Test 4: POST SPARQL query"
curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  -d "SELECT * WHERE { ?s ?p ?o } LIMIT 5" \
  -o /dev/null -w "POST query status: %{http_code}\n" \
  "${BASE_URL}/${FUSEKI_DATASET}/query"

# If you have authentication configured:
echo "Test 5: Authenticated admin operation"
curl -s --user "admin:admin123" \
  -o /dev/null -w "Admin status: %{http_code}\n" \
  "${BASE_URL}/$/stats"

echo "Tests complete."
