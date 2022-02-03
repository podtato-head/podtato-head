#!/usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
image_repo=${3:-${IMAGE_REPO:-"ghcr.io/podtato-head"}}

if [[ -n ${github_user} && -n ${github_token} ]]; then
  echo "${github_token}" | docker login ${image_repo} --username="${github_user}" --password-stdin &> /dev/null
  if [[ "${github_user}" != 'podtato-head' ]]; then
      image_repo=ghcr.io/${github_user}/podtato-head
  fi
fi

TAGS=("0.1.0" "0.1.1" "0.1.2")
for TAG in "${TAGS[@]}"; do
  docker build --rm=false --file "${app_dir}/docker/DockerfileV${TAG}" \
    --build-arg "GITHUB_USER=${github_user}" \
    --tag "${image_repo}/podtatoserver:v${TAG}" \
    "${app_dir}"
  if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
    docker push "${image_repo}/podtatoserver:v${TAG}"
  fi
done