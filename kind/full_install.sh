#!/usr/bin/env bash

echo "Creating KIND cluster "

kind create cluster --config=./cluster.yaml

echo "Installing traefik"

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik -f traefik_values.yaml

echo "Exposing traefik dashboard"

kubectl apply -f ./traefik_dashboard.yaml
