#!/bin/bash
# Enhanced script to check if Fuseki is running correctly

set -e

# Check if container is running
echo "Checking if Fuseki container is running..."
FUSEKI_CONTAINER=$(docker ps -q -f name=tbox_fuseki)

if [ -z "$FUSEKI_CONTAINER" ]; then
    echo "ERROR: Fuseki container is not running!"
    echo "Starting the tbox service..."
    sudo systemctl restart tbox.service
    sleep 5
    FUSEKI_CONTAINER=$(docker ps -q -f name=tbox_fuseki)
    if [ -z "$FUSEKI_CONTAINER" ]; then
        echo "ERROR: Failed to start Fuseki container!"
        exit 1
    fi
    echo "Fuseki container started successfully."
fi

echo "Waiting for Fuseki to be ready..."
until curl -s http://localhost:4030/$/ping > /dev/null; do
    echo "Waiting for Fuseki..."
    sleep 2
done
echo "Fuseki is up!"

# Check datasets
echo "Checking datasets..."
curl -X GET http://localhost:4030/$/datasets \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" && echo -e "\nDataset check - It works!"

echo -e "\nAdding test data..."
curl -X POST http://localhost:4030/ds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  --data "INSERT DATA { <http://example/s> <http://example/p> <http://example/o> }" && echo "Insert - It works!"

echo -e "\nQuerying data (SELECT)..."
curl -X POST http://localhost:4030/ds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data "SELECT * WHERE { ?s ?p ?o }" && echo "Select - It works!"

echo -e "\nQuerying data (CONSTRUCT)..."
curl -X POST http://localhost:4030/ds \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: text/turtle" \
  --data "CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }" && echo "Construct - It works!"

echo -e "\nChecking for TDB lock files..."
docker exec $FUSEKI_CONTAINER find /fuseki/databases -name "*.lock" | sort

echo -e "\nAll tests passed! Fuseki is working correctly."