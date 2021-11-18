#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

echo "github_user: ${github_user}"

namespace=podtato-kubectl
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'ghcr.io' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

cat "${this_dir}/manifest.yaml" | \
    sed "s@ghcr\.io\/podtato-head@ghcr.io/${github_user:+${github_user}/}podtato-head@g" | \
        kubectl apply -f -

kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-${part}
done
