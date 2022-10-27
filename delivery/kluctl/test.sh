#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi
source ${root_dir}/scripts/registry-secrets.sh

cd $this_dir

if [[ -z "${SKIP_INSTALL_KLUCTL}" ]]; then
  ## install kluctl CLI
  tmp_dir=$(mktemp -d)
  trap "rm -rf ${tmp_dir}" EXIT
  curl -s https://raw.githubusercontent.com/kluctl/kluctl/main/install/kluctl.sh | bash -s $tmp_dir
  export PATH=$tmp_dir:$PATH
  kluctl --version
fi

github_user=${1:-${GITHUB_USER}}
# altering 'GITHUB_USER' variable to be all lowercase since repo URLs must be all lowercase
github_user=$(echo $github_user | tr '[:upper:]' '[:lower:]')
github_token="${2:-${GITHUB_TOKEN}}"

# See https://kluctl.io/docs/reference/commands/environment-variables/#environment-variables-as-arguments
if [[ -n "${github_user}" ]]; then
  export KLUCTL_ARG_1=github_user=${github_user}
  if [[ "$github_user" != "podtato-head" ]]; then
    export KLUCTL_ARG_3=base_image=ghcr.io/${github_user}/podtato-head
  fi
fi
if [[ -n "${github_token}" ]]; then
  export KLUCTL_ARG_2=github_token=${github_token}
fi

image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)
echo "INFO: using tag: ${image_version}"

namespace=test-podtato-kluctl
kubectl config set-context --current --namespace ${namespace}

echo ""
echo "=== deploying test target"
kluctl deploy -t test -a image_version=${image_version} --yes

echo ""
echo "=== await readiness of deployments..."
kluctl validate -t test --wait 10m

${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-head-entry"
kubectl logs deployment/podtato-head-entry

echo ""
echo "=== kubectl logs deployment/podtato-head-hat"
kubectl logs deployment/podtato-head-hat

## -----------

echo ""
echo "=== creating podtato-prod-cluster context"
current_context=$(kubectl config current-context)
trap "kubectl config use-context $current_context" EXIT
current_cluster=$(kubectl config view --flatten -ojson | jq -r ".contexts[] | select(.name==\"$current_context\").context.cluster" )
current_user=$(kubectl config view --flatten -ojson | jq -r ".contexts[] | select(.name==\"$current_context\").context.user" )
kubectl config set-context podtato-prod-cluster --cluster $current_cluster --user $current_user

namespace=prod-podtato-kluctl
kubectl config set-context podtato-prod-cluster --namespace ${namespace}

echo ""
echo "=== deploying prod target"
kluctl deploy -t prod --yes

echo ""
echo "=== await readiness of deployments..."
kluctl validate -t prod --wait 10m

kubectl config use-context podtato-prod-cluster
${root_dir}/scripts/test_services.sh ${namespace}

echo ""
echo "=== kubectl logs deployment/podtato-head-entry"
kubectl logs deployment/podtato-head-entry

echo ""
echo "=== kubectl logs deployment/podtato-head-hat"
kubectl logs deployment/podtato-head-hat

## -----------

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo ""
echo "=== delete all"
kluctl delete -t test --yes
kluctl delete -t prod --yes