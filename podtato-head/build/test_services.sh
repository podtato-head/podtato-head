#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

temp_dir=$(mktemp -d)

kind_ver=0.11.1
curl -sSLo ${temp_dir}/kind https://github.com/kubernetes-sigs/kind/releases/download/v${kind_ver}/kind-linux-amd64
chmod +x ${temp_dir}/kind
export PATH=${temp_dir}:${PATH}

export KUBECONFIG=${temp_dir}/kube.config

${temp_dir}/kind version
${temp_dir}/kind create cluster --kubeconfig ${KUBECONFIG} --wait 60s

kubectl cluster-info

echo ""
echo "=== Testing kubectl deployment..."
${root_dir}/delivery/kubectl/test.sh "${github_user}" "${github_token}"

echo ""
if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    read -N 1 -s -p "press a key to delete cluster..."
fi

echo ""
echo ""
${temp_dir}/kind delete cluster
exit ${ret}
