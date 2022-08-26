#!/usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
source ${root_dir}/scripts/build-image.sh

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
image_repo=${3:-${IMAGE_REPO:-"ghcr.io/podtato-head"}}
base_run_image=${4:-scratch}
tag_suffix=${5#-}
push_too=${6:-false}

if [[ -n "${github_user}" ]]; then
    image_repo=ghcr.io/${github_user}/podtato-head
fi

if [[ -n ${github_user} && -n ${github_token} ]]; then
    echo "${github_token}" | docker login ${image_repo} --username="${github_user}" --password-stdin &> /dev/null
fi

TAGS=("0.1.0" "0.1.1" "0.1.2")
for TAG in "${TAGS[@]}"; do
    build_image \
        "${image_repo}/podtatoserver" \
        "v${TAG}${tag_suffix:+-${tag_suffix}}" \
        '' \
        "${app_dir}" \
        "docker/DockerfileV${TAG}" \
        "${base_run_image}" \
        "${github_user}" \
        "${push_too}"
done
