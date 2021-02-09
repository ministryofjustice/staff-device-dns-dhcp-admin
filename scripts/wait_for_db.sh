#!/bin/bash

set -euo pipefail

printf "Waiting for database to be ready"
count=0
until docker-compose exec -T db //bin//bash -c 'mysql -h127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"' &> /dev/null
do
  printf "."
  sleep 1
  (( count++ )) || true

  if [ "$count" -ge 10 ]; then
    echo "Failed to start server"
    docker-compose logs
    exit 1
  fi
done
