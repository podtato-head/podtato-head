#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
source ${root_dir}/scripts/registry-secrets.sh

github_user=${1:-${GITHUB_USER}}
# altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
github_user=${github_user,,}
github_token=${2:-${GITHUB_TOKEN}}
image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)

echo "github_user: ${github_user}"

namespace=podtato-kubectl
kubectl create namespace ${namespace} --save-config || true &> /dev/null
kubectl config set-context --current --namespace ${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    install_ghcr_secret "${namespace}" "${github_user}" "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

if [[ -z "${RELEASE_BUILD}" ]]; then
    # replace ghcr.io/podtato-head/body with ghcr.io/podtato-head/<github_user>/body for tests
    cat "${this_dir}/manifest.yaml" | \
        sed -E "s@ghcr\.io\/podtato-head/(.*)\:\S+@ghcr\.io\/podtato-head/\\1:${image_version}@g" | \
        sed -E "s@ghcr\.io\/podtato-head@ghcr.io/${github_user}/podtato-head@g" | \
            kubectl apply -f -
else
    kubectl apply -f ${this_dir}/manifest.yaml
fi

kubectl get deployments --namespace=${namespace}

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

kubectl delete namespace ${namespace}
