#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
image_repo=${3:-${IMAGE_REPO:-"ghcr.io/podtato-head"}}
tag_suffix=${4#-}

if [[ "${github_user}" != 'podtato-head' ]]; then
    image_repo=ghcr.io/${github_user}/podtato-head
fi

if [[ -n ${github_user} && -n ${github_token} ]]; then
  echo "${github_token}" | docker login ${image_repo} --username="${github_user}" --password-stdin &> /dev/null
fi

echo "run image: ${image_repo}/podtatoserver:v0.1.0${tag_suffix:+-${tag_suffix}}"
cid=$(docker run -p 9000:9000 -d ${image_repo}/podtatoserver:v0.1.0${tag_suffix:+-${tag_suffix}})
trap "docker container rm --force ${cid}" EXIT

sleep 2

echo "get home page"
curl -fs http://localhost:9000/ > /dev/null
if [[ $? != 0 ]]; then
    >&2 echo "ERROR: failed to get home page"
else
    echo "SUCCESS"
fi

echo "get static asset"
curl -fs http://localhost:9000/static/images/left-arm/left-arm-01.svg > /dev/null
if [[ $? != 0 ]]; then
    >&2 echo "ERROR: failed to get static asset"
else
    echo "SUCCESS"
fi

echo "don't get non-existent static asset"
curl -fs http://localhost:9000/static/images/left-arm/left-arm-07.svg > /dev/null
if [[ $? != 22 ]]; then
    >&2 echo "ERROR: got static asset unexpectedly"
else
    echo "SUCCESS"
fi

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to stop image..."
    echo ""
fi
