#!/usr/bin/env bash

echo "---------------------------------------------------"
echo "Installing Kapp..."
echo "---------------------------------------------------"
kapp_version=v0.35.0
binary_type=linux-amd64
curl -sL https://github.com/k14s/kapp/releases/download/${kapp_version}/kapp-${binary_type} > /tmp/kapp
sudo mv /tmp/kapp /usr/local/bin/kapp
sudo chmod +x /usr/local/bin//kapp
echo "Installed /usr/local/bin/kapp"

kapp version