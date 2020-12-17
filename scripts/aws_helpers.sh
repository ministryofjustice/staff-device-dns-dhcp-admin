#!/bin/bash

set -euo pipefail

get_network_config() {
  local cluster_name="${1}"
  local service_name="${2}"

  aws ecs describe-services \
        --cluster "${cluster_name}" \
        --services "${service_name}" \
        --output json \
        --query 'services[0].networkConfiguration'
}

get_launch_type() {
  local cluster_name="${1}"
  local service_name="${2}"

  aws ecs describe-services \
        --cluster "${cluster_name}" \
        --services "${service_name}" \
        --output text \
        --query 'services[0].launchType'
}

run_task_with_command() {
  local cluster_name="${1}"
  local service_name="${2}"
  local task_definition="${3}"
  local docker_service_name="${4}"
  local command="${5}"
  local network_config launch_type

  network_config="$(get_network_config "${cluster_name}" "${service_name}")"
  launch_type="$(get_launch_type "${cluster_name}" "${service_name}")"

  aws ecs run-task \
        --cluster "${cluster_name}" \
        --task-definition "${task_definition}" \
        --launch-type "${launch_type}" \
        --network-configuration "${network_config}" \
        --count 1 \
        --override "$(override_command_structure "${docker_service_name}" "${command}")"
}

form_command_override() {
  local override_command="${1}"
  override_command="${override_command}" python -c \
    'import os,json,shlex; print(json.dumps(shlex.split(os.environ["override_command"])))'
}

override_command_structure() {
  local docker_service="${1}"
  local command="${2}"

  cat <<EOF
  {
    "containerOverrides": [
      {
        "name": "${docker_service}",
        "command": $(form_command_override "${command}")
      }
    ]
  }
EOF
}
