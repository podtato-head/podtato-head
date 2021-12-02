#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

echo "github_user: ${github_user}"

namespace=podtato-kustomize
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'ghcr.io' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

echo ""
echo "=== apply base"

# TODO: kustomize provides typed commands for modifying image names, use that instead
if [[ -z "${RELEASE_BUILD}" ]]; then
    echo "INFO: prep kustomization.yaml to use ghcr.io/${github_user}/podtato-head/..."
    cp ${this_dir}/base/kustomization.yaml ${this_dir}/base/original_k.yaml
    trap "mv ${this_dir}/base/original_k.yaml ${this_dir}/base/kustomization.yaml" EXIT
    # includes an extra line in case original file doesn't end with EOL
    cat >> ${this_dir}/base/kustomization.yaml <<EOF

images:
  - name: ghcr.io/podtato-head/entry
    newName: ghcr.io/${github_user}/podtato-head/entry
  - name: ghcr.io/podtato-head/hat
    newName: ghcr.io/${github_user}/podtato-head/hat
  - name: ghcr.io/podtato-head/right-leg
    newName: ghcr.io/${github_user}/podtato-head/right-leg
  - name: ghcr.io/podtato-head/right-arm
    newName: ghcr.io/${github_user}/podtato-head/right-arm
  - name: ghcr.io/podtato-head/left-leg
    newName: ghcr.io/${github_user}/podtato-head/left-leg
  - name: ghcr.io/podtato-head/left-arm
    newName: ghcr.io/${github_user}/podtato-head/left-arm
EOF
fi

kustomize build ${this_dir}/base | kubectl apply -f -

kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-entry"
kubectl logs deployment/podtato-entry

echo ""
echo "=== kubectl logs deployment/podtato-hat"
kubectl logs deployment/podtato-hat

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo "=== delete all"
kustomize build ${this_dir}/base | kubectl delete -f -
kubectl delete namespace ${namespace}

## -----------

echo ""
echo "=== apply with overlay"
namespace=${namespace}-production
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'ghcr.io' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

kustomize build ${this_dir}/overlay | kubectl apply -f -

kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-entry"
kubectl logs deployment/podtato-entry

echo ""
echo "=== kubectl logs deployment/podtato-hat"
kubectl logs deployment/podtato-hat

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo "=== delete all"
kustomize build ${this_dir}/overlay | kubectl delete -f -
kubectl delete namespace ${namespace} 2> /dev/null || true
