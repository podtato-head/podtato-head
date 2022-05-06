#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

source ${root_dir}/scripts/registry-secrets.sh

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
export image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)

echo "github_user: ${github_user}"

namespace=podtato-helm
kubectl create namespace ${namespace} --save-config &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    install_ghcr_secret ${namespace} "${github_user}" "${github_token}"
fi

export oidc_enabled=false
if [[ -n "${OIDC_CLIENT_SECRET}" && -z "${OIDC_BYPASS}" ]]; then
    oidc_enabled=true
fi

export image_repo_dir_name=ghcr.io/podtato-head
if [[ -z "${RELEASE_BUILD}" ]]; then
    export image_repo_dir_name=ghcr.io/${github_user:+${github_user}/}podtato-head
fi

values_file="$(mktemp -d)/overrides.yaml"
cat ${this_dir}/overrides.yaml.tpl | envsubst > ${values_file}
helm upgrade --install podtato-head ${this_dir} --values ${values_file}

echo ""
echo "=== get deployments..."
kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of all deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=60s deployment --namespace ${namespace} podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to continue..."
    echo ""
fi

kubectl delete namespace ${namespace}
