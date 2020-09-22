#!/bin/bash

set -v -e -u -o pipefail

mysql -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} --ssl-ca=/usr/src/cert/rds-combined-ca-bundle.pem --ssl-mode=VERIFY_IDENTITY -e "ALTER USER '${DB_USER}'@'%' REQUIRE SSL;"
