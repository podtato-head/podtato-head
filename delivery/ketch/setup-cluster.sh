#! /usr/bin/env bash

## install cert-manager
certmanager_version=1.6.1
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v${certmanager_version}/cert-manager.yaml
kubectl wait --for=condition="Available" deployment -n cert-manager cert-manager
kubectl wait --for=condition="Available" deployment -n cert-manager cert-manager-webhook

## install a ClusterIssuer
kubectl apply -f - <<EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: selfsigned-cluster-issuer
    spec:
      selfSigned: {}
EOF

## install istio
tmp_dir=$(mktemp -d)
pushd "${tmp_dir}"
curl -sSL https://istio.io/downloadIstio | sh -
cp ./istio-*/bin/istioctl ./istioctl
./istioctl version
./istioctl install --set profile=demo --skip-confirmation
popd && rm -rf "${tmp_dir}"

## install ketch controller
ketch_version=0.6.1
kubectl apply -f https://github.com/shipa-corp/ketch/releases/download/v${ketch_version}/ketch-controller.yaml
kubectl wait --for=condition="Available" deployment ketch-controller-manager -n ketch-system

## install ketch CLI
curl -s https://raw.githubusercontent.com/shipa-corp/ketch/main/install.sh | bash
ketch --version