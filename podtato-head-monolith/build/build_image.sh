#!/usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)

REPOSITORY="ghcr.io/podtato-head"
TAGS=("0.1.0" "0.1.1" "0.1.2")
for TAG in "${TAGS[@]}"; do
  docker build --rm=false --file "${app_dir}/docker/DockerfileV${TAG}" \
    --tag "${REPOSITORY}/podtatoserver:v${TAG}" \
    "${app_dir}"
  if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
    docker push "${REPOSITORY}/podtatoserver:v${TAG}"
  fi
done