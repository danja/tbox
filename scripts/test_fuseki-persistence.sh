#!/bin/bash

echo "Waiting for Fuseki to be ready..."
until curl -s http://localhost:4030/$/ping > /dev/null; do
    echo "Waiting for Fuseki..."
    sleep 2
done
echo "Fuseki is up!"

echo "Adding test data..."
curl -X POST http://localhost:4030/ds/update \
  -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
  -H "Content-Type: application/sparql-update" \
  --data "INSERT DATA { <http://example/s> <http://example/p> <http://example/o> }"

echo -e "\nRestarting containers..."
docker-compose restart

echo "Waiting for Fuseki to be ready again..."
until curl -s http://localhost:4030/$/ping > /dev/null; do
    echo "Waiting for Fuseki..."
    sleep 2
done

echo -e "\nQuerying data..."
curl -X GET http://localhost:4030/ds/query \
  -H "Accept: application/sparql-results+json" \
  --data-urlencode "query=SELECT * WHERE { ?s ?p ?o }"