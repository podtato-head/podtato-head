#! /usr/bin/env bash

set -e

github_user=${1:-cncf}
github_token=${2}
ci_version=${3:-latest-dev}

echo "ci_version: ${ci_version}, github_user: ${github_user}"

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
namespace=podtato-kubectl
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'https://ghcr.io/' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

if [[ "${github_user}" != "cncf" ]]; then
    cat "${this_dir}/manifest.yaml" | \
        sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user}/podtato-head@g" | \
        sed "s/latest-dev/${ci_version}/g" | \
            kubectl apply -f -
else
    cat "${this_dir}/manifest.yaml" | \
        sed "s/latest-dev/${ci_version}/g" | \
            kubectl apply -f -
fi

kubectl wait --for=condition=Available --timeout=30s \
    deployment --namespace ${namespace} podtato-main

kubectl get deployments --namespace=${namespace}
