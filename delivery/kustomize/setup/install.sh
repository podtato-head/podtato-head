#!/usr/bin/env bash

echo "---------------------------------------------------"
echo "Installing Kustomize..."
echo "---------------------------------------------------"
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

echo "Moving kustomize to /usr/local/bin..."
sudo mv ./kustomize /usr/local/bin/

echo "Kustomize $(kustomize version --short) is installed"