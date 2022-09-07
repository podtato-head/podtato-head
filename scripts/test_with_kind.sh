#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}
delivery_type=${3:-kustomize}

echo "INFO: installing kind"
temp_dir=$(mktemp -d)
kind_ver=0.14.0
curl -sSLo ${temp_dir}/kind https://github.com/kubernetes-sigs/kind/releases/download/v${kind_ver}/kind-linux-amd64
chmod +x ${temp_dir}/kind
export PATH=${temp_dir}:${PATH}
export KUBECONFIG=${temp_dir}/kube.config

echo "INFO: kind version" $(${temp_dir}/kind version)
${temp_dir}/kind create cluster --kubeconfig ${KUBECONFIG} --wait 60s

echo "INFO: Testing ${delivery_type} delivery"
${root_dir}/delivery/${delivery_type}/test.sh "${github_user}" "${github_token}"

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete cluster..."
    echo ""
fi

${temp_dir}/kind delete cluster
exit ${ret}
