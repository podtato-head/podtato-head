#! /usr/bin/env bash

github_user=${1}
github_token=${2}

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
root_dir=$(cd ${this_dir}/../.. && pwd)

if [[ -z "${SKIP_CLUSTER_SETUP}" ]]; then ${this_dir}/setup-cluster.sh; fi

namespace=podtato-ketch
kubectl create namespace ${namespace} --save-config &> /dev/null
kubectl config set-context --current --namespace=${namespace}

if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    # ghcr secret in podtato-ketch
    kubectl delete secret ghcr &> /dev/null
    kubectl create secret docker-registry ghcr \
        --docker-server 'https://ghcr.io/' \
        --docker-username "${github_user}" \
        --docker-password "${github_token}"
    kubectl patch serviceaccount default \
        --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
fi

## get node address and port
INGRESS_PORT=$(kubectl get services -n ingress-nginx ingress-nginx-controller  -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
INGRESS_HOST=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

## add ketch framework
FRAMEWORK="framework1"
ketch framework list | grep -q $FRAMEWORK
if [[ $? != 0 ]]; then
    echo "----> ketch framework add:"
    ketch framework add $FRAMEWORK \
        --namespace podtato-ketch \
        --app-quota-limit '-1' \
        --cluster-issuer selfsigned-cluster-issuer \
        --ingress-class-name nginx \
        --ingress-type nginx \
        --ingress-service-endpoint "${INGRESS_HOST}"
    ketch framework export $FRAMEWORK
fi

waitForApp() {
  local app=$1
  echo "----> awaiting deployment available for $1..."
  sleep 3
  output=$(kubectl wait --for=condition=Available deployment --selector "theketch.io/app-name==$1" --timeout=60s)
  echo "$output"
}
imageDeploy() {
  local app=$1
  local framework="${2:-$FRAMEWORK}"
  local imageUrl="${3:-"ghcr.io/podtato-head/$1:latest"}"
  echo "----> ketch app deploy: $app"
  ketch app deploy "$app" \
      --framework "$framework" \
      --ketch-yaml "${this_dir}"/ketch-"$app".yaml \
      --image "$imageUrl"

  waitForApp "$app"
}

if [[ "${RUN_PODATOHEAD_SERVER}" ]]; then
  ## add ketch app
  ## must login _locally_ for image push, _in cluster_ for image pull
  echo "----> ketch app deploy:"
  # docker login ghcr.io --username ${github_user} --password "${github_token}"
  ketch app deploy podtato-head "${root_dir}/podtato-head-server" \
      --registry-secret ghcr \
      --builder gcr.io/buildpacks/builder:v1 \
      --framework $FRAMEWORK \
      --ketch-yaml ${this_dir}/ketch.yaml \
      --image ghcr.io/${github_user}/podtato-head/ketch-main:latest \
      --env "STATIC_DIR=/workspace/static/"

  echo "----> ketch app info:"
  ketch app info podtato-head

  waitForApp podtato-head

  ## test ketch app
  INGRESS_HOSTNAME=$(ketch app info podtato-head | grep '^Address' | sed -E 's/.*https?\:\/\/(.*)$/\1/')
  echo "----> testing deployment at http://${INGRESS_HOSTNAME}:${INGRESS_PORT}/"
  curl http://${INGRESS_HOSTNAME}:${INGRESS_PORT}/
  echo ""
  # curl http://${INGRESS_HOST}:${INGRESS_PORT}/
else
  imageDeploy hat
  imageDeploy left-arm
  imageDeploy left-leg
  imageDeploy right-arm
  imageDeploy right-leg

  echo "----> ketch app deploy: entry"

  # TODO: Replace with current image by official latest after this PR merges. Alternative is to
  #       deploy using source/buildpack but not sure how we can use buildpack given how source code is
  #       organize
  ketch app deploy entry \
      --framework $FRAMEWORK \
      --ketch-yaml ${this_dir}/ketch-entry.yaml \
      --image vivekpandey/entry:0.2.1-ketch \
      --env HAT_HOST=app-hat \
      --env LEFT_LEG_HOST=app-left-leg \
      --env LEFT_ARM_HOST=app-left-arm \
      --env RIGHT_ARM_HOST=app-right-arm \
      --env RIGHT_LEG_HOST=app-right-leg

  waitForApp entry

  ## test ketch app
  sleep 5
  INGRESS_HOSTNAME=$(ketch app info entry | grep '^Address' | sed -E 's/.*https?\:\/\/(.*)$/\1/')
  echo "----> testing deployment at http://${INGRESS_HOSTNAME}:${INGRESS_PORT}/"
  response=$(curl -v http://${INGRESS_HOSTNAME}:${INGRESS_PORT}/)
  echo $response
  if echo "$response" | grep -q "Hello Podtato!"; then
    echo "Success"
  else
    echo "Failed"
    exit 1
  fi
fi
