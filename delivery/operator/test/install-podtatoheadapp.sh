#! /usr/bin/env bash

# this_dir
# root_dir
# operator_name
# app_name
# app_namespace
# github_user
# github_token

kubectl create namespace ${app_namespace} &> /dev/null || true
kubectl config set-context --current --namespace=${app_namespace}

source ${root_dir}/scripts/registry-secrets.sh
install_ghcr_secret ${app_namespace} "${github_user}" "${github_token}"

# install PodtatoHeadApp resource
kubectl apply -f - <<EOF
apiVersion: apps.podtato-head.io/v1alpha1
kind: PodtatoHeadApp
metadata:
  name: ${app_name}
  namespace: ${app_namespace}
spec:
  fullnameOverride: podtato-head
  entry:
    serviceType: NodePort
  images:
    repositoryDirname: ghcr.io/${github_user,,}/podtato-head
EOF

echo ""
echo "=== await readiness of podtatoheadapp..."
kubectl wait -n ${app_namespace} --for=condition=Deployed --timeout=60s podtatoheadapp ${app_name}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=60s deployment --namespace ${app_namespace}  podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${app_namespace}
