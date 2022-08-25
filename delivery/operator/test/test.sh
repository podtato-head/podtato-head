#! /usr/bin/env bash

# by default exit and report failure on error
set -e

# export vars for ease of use in child scripts
set -o allexport

# make these readonly so child scripts can't accidentally modify them
declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r operator_dir=$(cd ${this_dir}/.. && pwd)
declare -r delivery_dir=$(cd ${this_dir}/../.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../../.. && pwd)

# let users specify local env vars in ./.env, e.g. GITHUB_USER and GITHUB_TOKEN
if [[ -f "${root_dir}/.env" ]]; then source "${root_dir}/.env"; fi

# import functions for managing ghcr.io secret
source ${root_dir}/scripts/registry-secrets.sh

# declare vars for all scripts
operator_name=podtato-head-operator
operator_version=${OPERATOR_VERSION:-0.0.1}
# in OpenShift: `openshift-operators`
operators_namespace=operators

olm_namespace=olm
catalog_name=podtato-head-catalog
catalog_namespace=${olm_namespace}

image_registry=${IMAGE_REGISTRY:-ghcr.io}
github_user=${1:-${GITHUB_USER}}
# altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
github_user=${github_user,,}
github_token=${2:-${GITHUB_TOKEN}}

app_name=podtato-head-app-01
app_namespace=${operator_name}-app

# most of the time we want to use a fork-specific URL for tests
# before release we want to use the official public URL
image_base_url=
if [[ -n "${github_user}" && -z "${RELEASE_BUILD}" ]]; then
    export image_base_url=${image_registry}/${github_user}/podtato-head/operator
else
    export image_base_url=${image_registry}/podtato-head/operator
fi

echo "github_user: ${github_user:-'NULL'}"
echo "operator image base URL: ${image_base_url:-'NULL'}"

### start real work...

echo ""
echo "=== installing operator framework"
# sourced so it can modify PATH if needed
source ${this_dir}/install-operator-framework.sh

echo ""
echo "=== building and pushing operator-related images"
${this_dir}/build-and-push-operator.sh

echo ""
echo "=== deploying catalog and subscription for operator"
${this_dir}/deploy-operator.sh

echo ""
echo "=== installing custom resource (app) managed by operator"
${this_dir}/install-podtatoheadapp.sh

if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    echo ""
    read -N 1 -s -p "press a key to delete resources..."
    echo ""
fi

echo ""
echo "=== tearing down resource, subscription, catalog, and OLM"
${this_dir}/teardown.sh
