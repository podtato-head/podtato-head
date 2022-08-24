#!/usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
image_repo=${3:-${IMAGE_REPO:-"ghcr.io/podtato-head"}}

if [[ "${github_user}" != 'podtato-head' ]]; then
    image_repo=ghcr.io/${github_user}/podtato-head
fi

if [[ -n ${github_user} && -n ${github_token} ]]; then
  echo "${github_token}" | docker login ${image_repo} --username="${github_user}" --password-stdin &> /dev/null
fi

function build_all_tags {
  local base_run_image=${1:-scratch}
  # remove starting dash if necessary, will add manually
  local extra_suffix=${2#-}

  TAGS=("0.1.0" "0.1.1" "0.1.2")
  for TAG in "${TAGS[@]}"; do
    docker build --rm=false --file "${app_dir}/docker/DockerfileV${TAG}" \
      --build-arg "GITHUB_USER=${github_user}" \
      --build-arg "BASE_RUN_IMAGE=${base_run_image}" \
      --tag "${image_repo}/podtatoserver:v${TAG}${extra_suffix:+-${extra_suffix}}" \
      "${app_dir}"
    if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
      docker push "${image_repo}/podtatoserver:v${TAG}${extra_suffix:+-${extra_suffix}}"
    fi
  done
}

## to build new tags, call `build_all_tags <base_image> <tag_suffix>`
## to add to tests, add a line to "test-server-images" referencing the tag_suffix
##      e.g. `test_image.sh '' '' '' distroless`
build_all_tags
build_all_tags gcr.io/distroless/static:latest distroless
build_all_tags registry.access.redhat.com/ubi8/ubi:latest ubi
build_all_tags distroless.dev/alpine-base chainguard
