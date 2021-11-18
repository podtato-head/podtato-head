#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)

version='0.1.0'
registry=ghcr.io
github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

if [[ -n "${github_token}" ]]; then
    echo "${github_token}" | docker login --username=${github_user} --password-stdin ${registry}
fi

container_name=${registry}/${github_user}/podtato-head/entry
echo "building container for entry as ${container_name}"
docker build ${root_dir} \
    --tag "${container_name}:latest" \
    --tag "${container_name}:${version}" \
    --build-arg "GITHUB_USER=${github_user}" \
    --file ${root_dir}/cmd/entry/Dockerfile
if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
    docker push "${container_name}:latest"
    docker push "${container_name}:${version}"
fi

parts=($(find ./pkg/assets/images/* -type d -printf '%f\n'))
for part in "${parts[@]}"; do
    container_name=${registry}/${github_user}/podtato-head/${part}
    echo "building container for ${part} as ${container_name}"
    docker build ${root_dir} \
        --tag "${container_name}:latest" \
        --tag "${container_name}:${version}" \
        --build-arg "PART=${part}" \
        --build-arg "GITHUB_USER=${github_user}" \
        --file ${root_dir}/cmd/parts/Dockerfile
    if [[ -n "${PUSH_TO_REGISTRY}" ]]; then
        docker push "${container_name}:latest"
        docker push "${container_name}:${version}"
    fi
    # docker run --rm -it -p 9000:9000 ${container_name}
done