#!/usr/bin/env bash

echo "---------------------------------------------------"
echo "Installing Kapp..."
echo "---------------------------------------------------"
kapp_version=v0.35.0
binary_type=linux-amd64
curl -sL https://github.com/k14s/kapp/releases/download/${kapp_version}/kapp-${binary_type} > /tmp/kapp
sudo mv /tmp/kapp /usr/local/bin/kapp
sudo chmod +x /usr/local/bin//kapp
echo "kapp Installed."

kapp version

echo
echo "NOTE : You can add autocompletion with :"
echo ' - bash      : source <(kapp completion bash)'
echo ' - ZSH       : source <(kapp completion zsh)'
echo ' - Oh-My-ZSH : kapp completion zsh --tty=false > "${fpath[1]}/_kapp'
echo