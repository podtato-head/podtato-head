#! /usr/bin/env bash

set -e

github_user=${1}
github_token=${2}

this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
export GITHUB_TOKEN=${GITHUB_TOKEN:-${github_token}}

gh_version=2.2.0
curl -sSLO https://github.com/cli/cli/releases/download/v${gh_version}/gh_${gh_version}_linux_amd64.tar.gz
tar -xzf gh_${gh_version}_linux_amd64.tar.gz \
    gh_${gh_version}_linux_amd64/bin/gh \
    --strip-components=2
mv ./gh ${this_dir}/gh
chmod +x ${this_dir}/gh
alias gh=${this_dir}/gh
rm -rf gh_${gh_version}_linux_amd64.tar.gz
gh version

curl -s https://fluxcd.io/install.sh | bash
flux version --client
flux install --version=latest

secret_ref_name=podtato-flux-secret
git_source_name=podtato-flux-repo
git_repo_url=https://github.com/${github_user}/podtato-head
helmrelease_name=podtato-flux-release
namespace=podtato-flux

if [[ -n "${USE_SSH_GIT_AUTH}" ]]; then
    git_repo_url=ssh://git@github.com/${github_user}/podtato-head
    flux create secret git ${secret_ref_name} --url=${git_repo_url}
    ssh_public_key=$(kubectl get secret ${secret_ref_name} -n flux-system -ojson | jq -r '.data."identity.pub" | @base64d')
    gh api repos/joshgav/podtato-head/keys | jq -r '.[].url' | sed 's/^https:\/\/api.github.com\///' | xargs -L 1 -r gh api --method DELETE
    gh api repos/${github_user}/podtato-head/keys \
        -F title=${secret_ref_name} \
        -F "key=${ssh_public_key}"
    sleep 3
else
    flux create secret git ${secret_ref_name} \
        --url=${git_repo_url} \
        --username "${github_user}" \
        --password "${github_token}"
fi

flux create source git ${git_source_name} \
    --url=${git_repo_url} \
    --secret-ref ${secret_ref_name} \
    --branch=main

kubectl create namespace ${namespace} &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}

# work around
tmp_values_file=$(mktemp)
echo -e "main:\n  serviceType: NodePort" > ${tmp_values_file}

flux create helmrelease ${helmrelease_name} \
    --target-namespace=${namespace} \
    --source=GitRepository/${git_source_name}.flux-system \
    --chart=./delivery/chart \
    --values="${tmp_values_file}"

if [[ -n "${github_token}" ]]; then
    test=$(kubectl get secret ghcr -oname 2> /dev/null || true)
    if [[ -z "${test}" ]]; then
      kubectl create secret docker-registry ghcr \
          --docker-server 'https://ghcr.io/' \
          --docker-username "${github_user}" \
          --docker-password "${github_token}"
    fi

    for sa in $(kubectl get serviceaccounts -oname); do
        kubectl patch ${sa} --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'
    done
fi

echo ""
echo "----> wait for deployment ready"
kubectl wait --for=condition=Available deployment --timeout=30s \
    --selector "app.kubernetes.io/component=${namespace}-${helmrelease_name}-podtato-head-main"

rm ${this_dir}/gh

if [[ -z "${PRESERVE_RESOURCES}" ]]; then
    echo ""
    echo "----> delete all"
    flux delete helmrelease ${helmrelease_name} --silent
    flux delete source git ${git_source_name} --silent
    kubectl delete namespace ${namespace}
fi
