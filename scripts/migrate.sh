#!/bin/bash

set -v -e -u -o pipefail

source ./scripts/aws-helpers.sh

function migrate() {
  local migration_command="./bin/rails db:migrate"
  local docker_service_name="admin"
  local cluster_name service_name task_definition docker_service_name

  cluster_name="staff-device-${ENV}-dhcp-admin-cluster"
  service_name="staff-device-${ENV}-dhcp-admin"
  task_definition="staff-device-${ENV}-dhcp-admin-task"

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${migration_command}"
}

migrate