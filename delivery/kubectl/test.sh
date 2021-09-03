#! /usr/bin/env bash

# set -e

github_user=${1:-cncf}
github_token=${2}
ci_version=${3:-latest-dev}

echo "ci_version: ${ci_version}, github_user: ${github_user}"
echo "obscured_token: $(echo ${github_token} | sed 's/./\*/g')"

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
namespace=podtato-kubectl
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" ]]; then
    kubectl create secret docker-registry ghcr --namespace ${namespace} \
        --docker-server 'ghcr.io' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default --namespace ${namespace} \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

kubectl get serviceaccount default -oyaml
kubectl get secret ghcr -oyaml
kubectl get secret ghcr -o jsonpath="{.data['\.dockerconfigjson']}" | base64 -d

docker login ghcr.io \
    --username ${github_user} \
    --password "${github_token}"

docker pull ghcr.io/cncf/podtato-head/podtato-main:v1-0.1.1-dev-PR-97

cat ${HOME}/.docker/config.json

echo "---> manifest to be applied"
cat "${this_dir}/manifest.yaml" | \
    sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user}/podtato-head@g" | \
    sed "s/latest-dev/${ci_version}/g"

cat "${this_dir}/manifest.yaml" | \
    sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user}/podtato-head@g" | \
    sed "s/latest-dev/${ci_version}/g" | \
        kubectl apply -f -

sleep 30
# kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-main

kubectl get events --namespace ${namespace}
kubectl logs --namespace ${namespace} -l 'app=podtato-head'

kubectl get deployments --namespace=${namespace}
