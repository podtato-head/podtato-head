#! /usr/bin/env bash

set -e

github_user=${1}
github_token=${2}

echo "github_user: ${github_user}"

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

cat "${this_dir}/manifest.yaml" | \
    sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user:+${github_user}/}podtato-head@g" | \
        kubectl apply -f -

kubectl wait --for=condition=Available --timeout=90s \
    deployment --namespace ${namespace} podtato-main

kubectl get deployments --namespace=${namespace}
