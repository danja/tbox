#!/bin/bash
# Script to check if Fuseki is running properly and test basic operations

set -e

# Function to check if Fuseki is responding
check_fuseki() {
  echo "Checking if Fuseki is running..."
  if curl -s -f http://localhost:4030/$/ping > /dev/null; then
    echo "✅ Fuseki is responding to ping"
    return 0
  else
    echo "❌ Fuseki is not responding to ping"
    return 1
  fi
}

# Function to test a dataset
test_dataset() {
  local dataset=$1
  echo "Testing dataset: $dataset"
  
  # Try a simple query
  echo "  Running SELECT query..."
  curl -s -f -X POST http://localhost:4030/$dataset/query \
    -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
    -H "Content-Type: application/sparql-query" \
    -H "Accept: application/sparql-results+json" \
    --data "SELECT * WHERE { ?s ?p ?o } LIMIT 1" > /dev/null
  
  if [ $? -eq 0 ]; then
    echo "  ✅ SELECT query successful"
  else
    echo "  ❌ SELECT query failed"
  fi
  
  # Try to insert some data
  echo "  Running INSERT DATA..."
  curl -s -f -X POST http://localhost:4030/$dataset/update \
    -H "Authorization: Basic $(echo -n 'admin:admin123' | base64)" \
    -H "Content-Type: application/sparql-update" \
    --data "INSERT DATA { <http://example.org/test> <http://example.org/property> \"Test from $(date)\" }" > /dev/null
  
  if [ $? -eq 0 ]; then
    echo "  ✅ INSERT DATA successful"
  else
    echo "  ❌ INSERT DATA failed"
  fi
}

# Main execution
echo "=== Fuseki Status Check ==="

# Wait for Fuseki to start up
echo "Waiting for Fuseki to start up (max 30 seconds)..."
timeout=30
count=0
while ! check_fuseki && [ $count -lt $timeout ]; do
  echo "  Still waiting... ($count/$timeout)"
  sleep 1
  count=$((count+1))
done

if [ $count -eq $timeout ]; then
  echo "❌ Timed out waiting for Fuseki to start"
  echo "Checking Docker logs:"
  docker compose logs fuseki | tail -n 50
  exit 1
fi

# If we're here, Fuseki is responding
echo "=== Testing Datasets ==="

# Test each dataset
for ds in ds test-mem test-db semem squirt tia claudiob danja danbri hyperdata; do
  test_dataset $ds
  echo ""
done

echo "=== All tests completed ==="
