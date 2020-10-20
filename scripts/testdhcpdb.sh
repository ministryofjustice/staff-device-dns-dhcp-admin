#!/bin/bash

set -v -e -u -o pipefail

source ./scripts/aws-helpers.sh

function testdhcpdb() {
  local command="mysql -u ${DHCP_DB_USER} -p${DHCP_DB_PASS} -n ${DHCP_DB_NAME} -h ${DHCP_DB_HOST}"
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
    "${command}"
}

testdhcpdb
