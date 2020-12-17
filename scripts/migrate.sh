#!/bin/bash

set -veuo pipefail

source ./scripts/aws_helpers.sh

assume_deploy_role() {
  TEMP_ROLE=`aws sts assume-role --role-arn $ROLE_ARN --role-session-name ci-dhcp-deploy-$CODEBUILD_BUILD_NUMBER`
  export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
}

migrate() {
  local migration_command="./bin/rails db:migrate"
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
