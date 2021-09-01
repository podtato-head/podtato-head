#! /usr/bin/env bash

github_user=${1:-cncf}
github_token=${2}
# ci_version=${3:-latest-dev}

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

namespace=podtato-helm
kubectl create namespace ${namespace} &> /dev/null
kubectl config set-context --current --namespace=${namespace}

kubectl create secret docker-registry ghcr \
    --docker-server 'https://ghcr.io/' \
    --docker-username "${github_user}" \
    --docker-password "${github_token}"

helm install --debug podtato-head ${this_dir} \
    --set "images.repositoryDirname=ghcr.io/${github_user}/podtato-head" \
    --set "images.pullSecrets[0].name=ghcr"

echo ""
echo "----> main deployment:"
kubectl get deployment --selector 'app.kubernetes.io/component=podtato-head-main' --output yaml

echo ""
echo "----> wait for ready"
kubectl wait --for=condition=ready pod --timeout=30s \
    --selector app.kubernetes.io/component=podtato-head-main --namespace=${namespace}
