#! /usr/bin/env bash

set -e

github_user=${1}
github_token=${2}

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

echo ""
echo "----> prep kustomization.yaml"
cp ${this_dir}/base/kustomization.yaml ${this_dir}/base/original_k.yaml
# includes an extra line in case original file doesn't end with EOL
cat >> ${this_dir}/base/kustomization.yaml <<EOF

images:
  - name: ghcr.io/podtato-head/podtato-main
    newName: ghcr.io/${github_user}/podtato-head/podtato-main
  - name: ghcr.io/podtato-head/podtato-hats
    newName: ghcr.io/${github_user}/podtato-head/podtato-hats
  - name: ghcr.io/podtato-head/podtato-right-leg
    newName: ghcr.io/${github_user}/podtato-head/podtato-right-leg
  - name: ghcr.io/podtato-head/podtato-right-arm
    newName: ghcr.io/${github_user}/podtato-head/podtato-right-arm
  - name: ghcr.io/podtato-head/podtato-left-leg
    newName: ghcr.io/${github_user}/podtato-head/podtato-left-leg
  - name: ghcr.io/podtato-head/podtato-lef-arm
    newName: ghcr.io/${github_user}/podtato-head/podtato-left-arm
EOF

echo ""
echo "----> apply base"
namespace=podtato-kustomize
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'https://ghcr.io/' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

kustomize build ${this_dir}/base | kubectl apply -f -

echo ""
echo "----> main deployment YAML:"
kubectl get deployment --selector 'app.kubernetes.io/component=main' --output yaml

echo ""
echo "----> wait for deployment ready"
kubectl wait --for=condition=Available deployment --timeout=30s --selector app.kubernetes.io/component=main

echo ""
echo "----> delete all"
kustomize build ${this_dir}/base | kubectl delete -f -

## -----------

echo ""
echo "----> apply with overlay"
namespace=${namespace}-production
kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" ]]; then
    kubectl create secret docker-registry ghcr \
        --docker-server 'https://ghcr.io/' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi
kustomize build ${this_dir}/overlay | kubectl apply -f -

echo ""
echo "----> main deployment YAML:"

kubectl get deployment --namespace=${namespace} --selector 'app.kubernetes.io/component=main' --output yaml

echo ""
echo "----> wait for deployment ready"
kubectl wait --for=condition=Available deployment --timeout=30s --namespace=${namespace} --selector app.kubernetes.io/component=main

echo ""
echo "----> delete all"
kustomize build ${this_dir}/overlay | kubectl delete -f -

mv ${this_dir}/base/original_k.yaml ${this_dir}/base/kustomization.yaml