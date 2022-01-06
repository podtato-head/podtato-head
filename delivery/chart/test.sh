#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

echo "github_user: ${github_user}"

namespace=podtato-helm
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    test=$(kubectl get secret ghcr -oname 2> /dev/null || true)
    if [[ -z "${test}" ]]; then
        kubectl create secret docker-registry ghcr \
            --docker-server 'ghcr.io/' \
            --docker-username "${github_user}" \
            --docker-password "${github_token}"
    fi
fi

if [[ -z "${RELEASE_BUILD}" ]]; then
    # replace ghcr.io/podtato-head/body with ghcr.io/podtato-head/<github_user>/body for tests and test changing hat part number
    helm upgrade --install podtato-head ${this_dir} \
        --set "images.repositoryDirname=ghcr.io/${github_user:+${github_user}/}podtato-head" \
        --set "hat.env[0].name=PODTATO_PART_NUMBER" --set "hat.env[0].value=02" \
        ${github_token:+--set "images.pullSecrets[0].name=ghcr"}
else
    helm upgrade --install podtato-head ${this_dir} \
        --set "hat.env[0].name=PODTATO_PART_NUMBER" --set "hat.env[0].value=02" \
        ${github_token:+--set "images.pullSecrets[0].name=ghcr"}
fi

kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to continue..."
    echo ""
fi

kubectl delete namespace ${namespace}
