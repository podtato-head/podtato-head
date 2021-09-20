#! /usr/bin/env bash

github_user=${1}
github_token=${2}

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)

namespace=podtato-ketch
kubectl create namespace ${namespace} --save-config &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    kubectl get secret ghcr &> /dev/null
    if [[ $? != 0 ]]; then
        kubectl create secret docker-registry ghcr \
            --docker-server 'https://ghcr.io/' \
            --docker-username "${github_user}" \
            --docker-password "${github_token}"

        kubectl create secret docker-registry ghcr --namespace=ketch-system \
            --docker-server 'https://ghcr.io/' \
            --docker-username "${github_user}" \
            --docker-password "${github_token}"
    fi

    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

${this_dir}/setup-cluster.sh

## get node address and port
INGRESS_PORT=$(kubectl get services -n istio-system istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
INGRESS_HOST=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

## add ketch framework
ketch framework list | grep -q framework1
if [[ $? != 0 ]]; then
    ketch framework add framework1 \
        --namespace podtato-ketch \
        --app-quota-limit '-1' \
        --cluster-issuer selfsigned-cluster-issuer \
        --ingress-class-name istio \
        --ingress-type istio \
        --ingress-service-endpoint "${INGRESS_HOST}"
    ketch framework export framework1
fi

## add ketch app
# ln --symbolic "${root_dir}/podtato-services/main/docker/Dockerfile" "${root_dir}/podtato-services/main/Dockerfile"
ketch app deploy podtato-head "${root_dir}/podtato-services/main" \
    --registry-secret ghcr \
    --builder paketobuildpacks/builder:full \
    --framework framework1 \
    --image ghcr.io/${github_user}/podtato-ketch/podtato-main:latest \
    --wait
rm "${root_dir}/podtato-services/main/Dockerfile"
ketch app info podtato-head

## test ketch app
curl -sSL http://${INGRESS_HOST}:${INGRESS_PORT}/