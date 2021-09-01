#! /usr/bin/env bash

github_user=${1:-cncf}
github_token=${2}
ci_version=${3:-latest-dev}

echo "ci_version: ${ci_version}, github_user: ${github_user}"

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
namespace=podtato-kubectl

kubectl create secret docker-registry ghcr \
    --docker-server 'https://ghcr.io/' \
    --docker-username "${github_user}" \
    --docker-password "${github_token}"

kubectl patch serviceaccount default \
    --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'

cat "${this_dir}/manifest.yaml" | \
    sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user}/podtato-head@g" | \
    sed "s/latest-dev/${ci_version}/g" | \
        kubectl apply -f -

kubectl wait --for=condition=Available deployment --namespace ${namespace} podtato-main

kubectl get deployments --namespace=${namespace}
