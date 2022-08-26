#! /usr/bin/env bash

### configurable env vars:
#
# GITHUB_USER: required for non-release builds. for login to ghcr.io, and to set a label on images
# GITHUB_TOKEN: required for pushing images. for login to ghcr.io
# COSIGN_KEY_PATH: optional. path to private key for cosign
# COSIGN_PASSWORD: optional. password for cosign private key
# IMAGE_VERSION: optional. if set, override default image tag. Default version is calculated by incrementing the previous _published_ tag.
# RELEASE_BUILD: optional. if set, push to ghcr.io/podtato-head rather than ghcr.io/<user>/podtato-head
# INCREMENT_MAJOR: optional. if set, increment major on release (default is to increment patch)
# INCREMENT_MINOR: optional. if set, increment minor on release (default is to increment patch)
# PUSH_TO_REGISTRY: optional. if set, push image to remote registry after building locally

### set paths
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -e ${root_dir}/.env ]]; then 
    echo "INFO: sourcing env vars from .env in repo root"
    source ${root_dir}/.env
fi

## import functions
source ${root_dir}/scripts/registry-secrets.sh
source ${root_dir}/scripts/build-image.sh

### set registry
registry_user=${1:-${GITHUB_USER}}
## must be lower case for container registries
registry_user=${registry_user,,}
registry_token=${2:-${GITHUB_TOKEN}}
registry_hostname=${3:-ghcr.io}
base_run_image=${4:-scratch}
## remove leading dash (we'll add as appropriate)
image_tag_suffix=${5#-}
push_too=${6:-false}

try_login_ghcr "${registry_user}" "${registry_token}"

### determine tag
image_version=$(${this_dir}/image_version.sh)
image_tag="${image_version}${image_tag_suffix:+-${image_tag_suffix}}"
echo "INFO: will use tag: ${image_tag}"

### prep cosign metadata
export COSIGN_KEY_PATH="${COSIGN_KEY_PATH:-${root_dir}/.github/workflows/cosign.key}"
export COSIGN_PASSWORD="${COSIGN_PASSWORD}"

### build, push and sign entry image
if [[ -z "${RELEASE_BUILD}" ]]; then
    image_name=${registry_hostname}/${registry_user}/podtato-head/entry
else
    image_name=${registry_hostname}/podtato-head/entry
fi

build_image \
    "${image_name}" \
    "${image_tag}" \
    '' \
    "${app_dir}" \
    cmd/entry/Dockerfile \
    "${base_run_image}" \
    "${registry_user}" \
    ${push_too}

### build parts images
parts=($(find ${app_dir}/pkg/assets/images/* -type d -printf '%f\n'))
for part in "${parts[@]}"; do
    if [[ -z "${RELEASE_BUILD}" ]]; then
        image_name=${registry_hostname}/${registry_user}/podtato-head/${part}
    else
        image_name=${registry_hostname}/podtato-head/${part}
    fi

    build_image \
        "${image_name}" \
        "${image_tag}" \
        "${part}" \
        "${app_dir}" \
        cmd/parts/Dockerfile \
        "${base_run_image}" \
        "${registry_user}" \
        ${push_too}
done
