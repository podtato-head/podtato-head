#! /usr/bin/env bash

# configurable env vars:
# GITHUB_USER
# GITHUB_TOKEN
# COSIGN_KEY_PATH
# COSIGN_PASSWORD
# VERSION: if set, override default version. Default version is previous tag for non-main branches, incremented tag for main
# RELEASE_BUILD: if set, push to ghcr.io/podtato-head, increment version from last tag, and possibly apply a git tag
# INCREMENT_MAJOR: if set, increment major on release (default is to increment minor)
# INCREMENT_PATCH: if set, increment patch (x.y.Z) on release (default is to increment minor)
# PUSH_TO_REGISTRY: if set, push image to remote registry after building locally

### set up build

# set common variables
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e ${root_dir}/.env ]]; then 
    echo "INFO: sourcing env vars from .env in repo root"
    source ${root_dir}/.env
fi
# /end set common variables

# set up registry access
registry=ghcr.io
github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
commit_sha=$(git rev-parse HEAD)

# sign in if possible
if [[ -z "${github_token}" ]]; then
    echo "WARNING: GITHUB_TOKEN not set, push may fail"
else
    echo "${github_token}" | docker login --username=${github_user} --password-stdin ${registry} &> /dev/null
fi
# /end set up registry access

# set version/tag for this build
source ${this_dir}/version.sh
version=$(version_to_use)
echo "INFO: will use version/tag: ${version}"
# /end set version

# set up cosign
sign_images=$(if type -P cosign > /dev/null; then echo 1; else echo 0; fi)
cosign_key_path=${COSIGN_KEY_PATH:-"${root_dir}/.github/workflows/cosign.key"}
if [[ ${sign_images} == 1 && -n "${COSIGN_PASSWORD}" ]]; then
    echo "INFO: will sign images using cosign version" \
        $(cosign version --json | jq -r '.GitVersion')
fi
# /end set up cosign

# set up trivy
scan_images=$(if type -P trivy > /dev/null; then echo 1; else echo 0; fi)
if [[ ${scan_images} == 1 ]]; then
    echo "INFO: will scan images using trivy version" \
        $(trivy --version | head -1 | sed -E 's/^Version: (.*)$/\1/')
fi
# /end set up trivy
### /end set up build

### build, push and sign entry container
if [[ -z "${RELEASE_BUILD}" ]]; then
    container_name=${registry}/${github_user}/podtato-head/entry
else
    container_name=${registry}/podtato-head/entry
fi

echo ""
echo "INFO: building container for entry as ${container_name}"
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
    echo "INFO: signing ${container_name}"
    cosign sign --key ${cosign_key_path} \
        --annotations git_commit=${git_commit} \
        --annotations version=${version} \
        ${container_name}:latest
fi
if [[ ${scan_images} == 1 ]]; then
    echo "INFO: scanning ${container_name}"
    trivy image \
        --format table \
        --severity "HIGH,CRITICAL" \
        --no-progress \
            ${container_name}
fi
### /end build, push and sign entry container

### build et al parts containers
parts=($(find ${app_dir}/pkg/assets/images/* -type d -printf '%f\n'))
for part in "${parts[@]}"; do
    if [[ -z "${RELEASE_BUILD}" ]]; then
        container_name=${registry}/${github_user}/podtato-head/${part}
    else
        container_name=${registry}/podtato-head/${part}
    fi
    echo ""
    echo "INFO: building container for ${part} as ${container_name}"
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
        echo "INFO: signing ${container_name}"
        cosign sign --key ${cosign_key_path} \
            --annotations git_commit=${git_commit} \
            --annotations version=${version} \
            ${container_name}:${version}
    fi
    if [[ ${scan_images} == 1 ]]; then
        echo "INFO: scanning ${container_name}"
        trivy image \
            --format table \
            --severity "HIGH,CRITICAL" \
            --no-progress \
                ${container_name}
    fi
done
### /end build et al parts containers