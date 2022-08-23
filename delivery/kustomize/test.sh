#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
source ${root_dir}/scripts/registry-secrets.sh

github_user=${1:-${GITHUB_USER}}
# altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
github_user=${github_user,,}
github_token="${2:-${GITHUB_TOKEN}}"

image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)
echo "INFO: using tag: ${image_version}"

namespace=podtato-kustomize
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    install_ghcr_secret ${namespace} "${github_user}" "${github_token}"
    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")

echo ""
echo "=== apply kustomize base"
if [[ -z "${RELEASE_BUILD}" ]]; then
    echo "INFO: use ghcr.io/${github_user}/podtato-head/entry${image_version:+:${image_version}}"

    # copy original and use a temp file for edits
    cp ${this_dir}/base/kustomization.yaml ${this_dir}/base/original_kustomization.yaml
    trap "mv ${this_dir}/base/original_kustomization.yaml ${this_dir}/base/kustomization.yaml" EXIT

    for part in "${parts[@]}"; do
        (cd ${this_dir}/base && kustomize edit set image ghcr.io/podtato-head/${part}=ghcr.io/${github_user}/podtato-head/${part}${image_version:+:${image_version}})
    done
fi

kustomize build ${this_dir}/base | kubectl apply -f -

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=60s deployment --namespace ${namespace} podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-head-entry"
kubectl logs deployment/podtato-head-entry

echo ""
echo "=== kubectl logs deployment/podtato-head-hat"
kubectl logs deployment/podtato-head-hat

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo ""
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
    install_ghcr_secret ${namespace} "${github_user}" "${github_token}"
    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

kustomize build ${this_dir}/overlay | kubectl apply -f -

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-head-entry"
kubectl logs deployment/podtato-head-entry

echo ""
echo "=== kubectl logs deployment/podtato-head-hat"
kubectl logs deployment/podtato-head-hat

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo ""
echo "=== delete all"
kustomize build ${this_dir}/overlay | kubectl delete -f -
kubectl delete namespace ${namespace} 2> /dev/null || true
