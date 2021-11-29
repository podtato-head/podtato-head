#! /usr/bin/env bash

# variables
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e ${root_dir}/.env ]]; then source ${root_dir}/.env; fi

version='0.1.0'
registry=ghcr.io
github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

sign_images=$(if type -P cosign > /dev/null; then echo 1; else echo 0; fi)
cosign_key_path=${COSIGN_KEY_PATH:-"${root_dir}/.github/workflows/cosign.key"}
git_sha=$(git rev-parse HEAD)

if [[ ${sign_images} == 1 && -n "${COSIGN_PASSWORD}" ]]; then
    echo "INFO: will sign images using cosign version $(cosign version --json | jq -r '.GitVersion')"
fi

if [[ -z "${github_token}" ]]; then
    echo "WARNING: GITHUB_TOKEN not set, push may fail"
else
    echo "${github_token}" | docker login --username=${github_user} --password-stdin ${registry} &> /dev/null
fi
# /variables

if [[ -z "${RELEASE_BUILD}" ]]; then
    container_name=${registry}/${github_user}/podtato-head/entry
else
    container_name=${registry}/podtato-head/entry
fi

echo "building container for entry as ${container_name}"
echo ""
docker build ${app_dir} \
    --tag "${container_name}:latest" \
    --tag "${container_name}:${version}" \
    --build-arg "GITHUB_USER=${github_user}" \
    --file ${app_dir}/cmd/entry/Dockerfile
if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
    docker push "${container_name}:latest"
    docker push "${container_name}:${version}"
fi
if [[ ${sign_images} == 1 && -n "${COSIGN_PASSWORD}" ]]; then
    echo "signing ${container_name}"
    echo ""
    cosign sign --key ${cosign_key_path} \
        --annotations git_sha=${git_sha} \
        --annotations version=latest \
        --annotations version=${version} \
        ${container_name}:latest

    cosign sign --key ${cosign_key_path} \
        --annotations git_sha=${git_sha} \
        --annotations version=${version} \
        ${container_name}:${version}
fi

parts=($(find ${app_dir}/pkg/assets/images/* -type d -printf '%f\n'))
for part in "${parts[@]}"; do
    if [[ -z "${RELEASE_BUILD}" ]]; then
        container_name=${registry}/${github_user}/podtato-head/${part}
    else
        container_name=${registry}/podtato-head/${part}
    fi
    echo "building container for ${part} as ${container_name}"
    echo ""
    docker build ${app_dir} \
        --tag "${container_name}:latest" \
        --tag "${container_name}:${version}" \
        --build-arg "PART=${part}" \
        --build-arg "GITHUB_USER=${github_user}" \
        --file ${app_dir}/cmd/parts/Dockerfile
    if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
        docker push "${container_name}:latest"
        docker push "${container_name}:${version}"
    fi
    if [[ "${sign_images}" == 1 && -n "${COSIGN_PASSWORD}" ]]; then
        echo "signing ${container_name}"
        echo ""
        cosign sign --key ${cosign_key_path} \
            --annotations git_sha=${git_sha} \
            --annotations version=latest \
            --annotations version=${version} \
            ${container_name}:latest

        cosign sign --key ${cosign_key_path} \
            --annotations git_sha=${git_sha} \
            --annotations version=${version} \
            ${container_name}:${version}
    fi
done