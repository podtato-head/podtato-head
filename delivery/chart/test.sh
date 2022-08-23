#! /usr/bin/env bash

set -e
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

source ${root_dir}/scripts/registry-secrets.sh

github_user=${1:-${GITHUB_USER}}
# altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
github_user=${github_user,,}
github_token=${2:-${GITHUB_TOKEN}}
image_version=$(${root_dir}/podtato-head-microservices/build/image_version.sh)

echo "github_user: ${github_user}"

namespace=podtato-helm
kubectl create namespace ${namespace} --save-config &> /dev/null || true
kubectl config set-context --current --namespace=${namespace}
if [[ -n "${github_token}" && -n "${github_user}" ]]; then
    install_ghcr_secret ${namespace} "${github_user}" "${github_token}"
fi

if [[ -z "${RELEASE_BUILD}" ]]; then
    # replace ghcr.io/podtato-head/body with ghcr.io/podtato-head/<github_user>/body for tests and test changing hat part number
    helm upgrade --install podtato-head ${this_dir} --values - <<EOF
        images:
            repositoryDirname: ghcr.io/${github_user:+${github_user}/}podtato-head
            pullSecrets:
              - name: ghcr
        entry:
            tag: ${image_version}
        hat:
            tag: ${image_version}
            env:
              - name: PODTATO_PART_NUMBER
                value: '02'
        rightLeg:
            tag: ${image_version}
        rightArm:
            tag: ${image_version}
        leftLeg:
            tag: ${image_version}
        leftArm:
            tag: ${image_version}
EOF
else
    helm upgrade --install podtato-head ${this_dir} --values - <<EOF
        images:
            pullSecrets:
              - name: ghcr
        entry:
            tag: ${image_version}
        hat:
            tag: ${image_version}
            env:
              - name: PODTATO_PART_NUMBER
                value: '02'
        rightLeg:
            tag: ${image_version}
        rightArm:
            tag: ${image_version}
        leftLeg:
            tag: ${image_version}
        leftArm:
            tag: ${image_version}
EOF
fi

kubectl get deployments --namespace=${namespace}

echo ""
echo "=== await readiness of deployments..."
parts=("entry" "hat" "left-leg" "left-arm" "right-leg" "right-arm")
for part in "${parts[@]}"; do
    kubectl wait --for=condition=Available --timeout=60s deployment --namespace ${namespace} podtato-head-${part}
done

${root_dir}/scripts/test_services.sh ${namespace}

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to continue..."
    echo ""
fi

kubectl delete namespace ${namespace}
