#!/bin/bash

set -euo pipefail

source ./scripts/aws_helpers.sh

migrate() {
  local migration_command="mysqladmin -h$DB_HOST -u$DB_USER -p$DB_PASS flush-hosts && ./bin/rails db:migrate"
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name="staff-device-${ENV}-dhcp-admin-cluster"
  service_name="staff-device-${ENV}-dhcp-admin"
  task_definition="staff-device-${ENV}-dhcp-admin-task"

  aws sts get-caller-identity

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${migration_command}"
}


main() {
  assume_deploy_role
  migrate
}

main
