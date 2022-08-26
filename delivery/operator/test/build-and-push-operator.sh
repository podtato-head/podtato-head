#! /usr/bin/env bash

# Utilizes operator-sdk to scaffold, build and push an operator based on a Helm chart.

# env vars:
# this_dir*
# delivery_dir*
# github_token
# github_user*
# image_registry*
# operator_name*
# operator_version*
# image_base_url*

# sanity check that we've inherited env vars
if [[ ! -v this_dir ]]; then exit; fi

helm_chart_path=${1:-${delivery_dir}/chart}

source ${root_dir}/scripts/registry-secrets.sh
try_login_ghcr "${github_user}" "${github_token}"

### init and build operator from chart
work_dir=${this_dir}/work
echo "work_dir: ${work_dir}"
if [[ -d ${work_dir} ]]; then
    echo "deleting previous work dir"
    rm -rf ${work_dir}
fi
mkdir -p ${work_dir}
pushd ${work_dir}

## init operator from chart
if [[ ! -e PROJECT ]]; then
    operator-sdk init --plugins 'helm.sdk.operatorframework.io/v1' --project-version=3 \
        --project-name ${operator_name} \
        --domain=podtato-head.io \
        --group=apps \
        --version=v1alpha1 \
        --kind=PodtatoHeadApp \
        --helm-chart=${helm_chart_path}
fi
### /end init operator from chart

# set vars for operator-sdk Makefile
export IMAGE_TAG_BASE=${image_base_url}
export IMG=${image_base_url}:latest
# TODO: research if the following would be more correct?
# export IMG=${image_base_url}:${operator_version}
export VERSION=${operator_version}

### build operator
make docker-build
label_ghcr_image "${image_base_url}:latest" "${github_user}/podtato-head"
make docker-push
### /end build operator

### build bundle
# to avoid prompts must provide info on bundle
mkdir -p config/manifests/bases
cp ${this_dir}/resources/${operator_name}.clusterserviceversion.yaml \
   ${work_dir}/config/manifests/bases/${operator_name}.clusterserviceversion.yaml
make bundle bundle-build
label_ghcr_image "${image_base_url}-bundle:v${operator_version}" "${github_user}/podtato-head"
make bundle-push
### /end build bundle

### build catalog
make catalog-build
label_ghcr_image "${image_base_url}-catalog:v${operator_version}" "${github_user}/podtato-head"
make catalog-push
### /end build catalog