#!/bin/bash

set -v -e -u -o pipefail

source ./scripts/aws_helpers.sh

function require_ssl() {
  local require_ssl_command="mysql -u ${DB_USER} -p${DB_PASS} -n ${DB_NAME} -h ${DB_HOST} --ssl-ca=/usr/src/cert/rds-combined-ca-bundle.pem -e \"ALTER USER '${DB_USER}'@'%' REQUIRE SSL;\""
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name="staff-device-${ENV}-dhcp-admin-cluster"
  service_name="staff-device-${ENV}-dhcp-admin"
  task_definition="staff-device-${ENV}-dhcp-admin-task"

  echo "${cluster_name}"
  echo "${service_name}"
  aws sts get-caller-identity
  echo "===================================================================================================="

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${require_ssl_command}"
}

require_ssl
