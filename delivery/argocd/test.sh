#! /usr/bin/env bash

set -e

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
source ${root_dir}/scripts/registry-secrets.sh

export github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
export image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)

echo "github_user: ${github_user}"

# install ArgoCD controller
argocd_namespace=argocd
kubectl create namespace ${argocd_namespace} &> /dev/null || true
kubectl apply --namespace ${argocd_namespace} \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# /end install ArgoCD controller

# install ArgoCD CLI
if ! type -p argocd; then
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x /usr/local/bin/argocd
fi
argocd version
# /end install ArgoCD CLI

# install application
export namespace=podtato-head-argocd
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" ]]; then
    install_ghcr_secret ${namespace} "${github_user}" "${github_token}"
fi

export git_repo_url=https://github.com/${github_user}/podtato-head
export git_repo_path=delivery/chart
export git_repo_tree=main
export application_name=podtato-head
export image_name_base=ghcr.io/${github_user:+joshgav/}podtato-head

export oidc_enabled=false
# if [[ -n "${OIDC_CLIENT_SECRET}" ]]; then
#     oidc_enabled=true
# fi
cat ${this_dir}/application.yaml.tpl | envsubst | kubectl apply -f -

argocd app sync ${application_name}

echo ""
echo "=== initial deployments state"
kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=30s deployment --namespace ${namespace} podtato-head-${part}
done

# service tests
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
argocd app delete ${application_name} --yes
kubectl delete namespace ${namespace}
