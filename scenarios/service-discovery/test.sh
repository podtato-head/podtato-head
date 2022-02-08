#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

namespace=podtato-helm
kubectl create namespace ${namespace} --save-config &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}

helm upgrade --install podtato-head-ext ${this_dir} \
    --set "images.repositoryDirname=ghcr.io/${GITHUB_USER}/podtato-head" \
    --set "hat.tag=test"
