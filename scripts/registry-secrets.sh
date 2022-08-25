function install_ghcr_secret {
    namespace=${1:-default}
    registry_username=${2:-${GITHUB_USER}}
    # altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
    registry_user=${registry_username,,}
    registry_password=${3:-${GITHUB_TOKEN}}

    secret_name=ghcr
    registry_host=${4:-ghcr.io}

    ## ensure namespace exists
    kubectl create namespace ${namespace} &> /dev/null || true

    if [[ -n "${registry_password}" && -n "${registry_username}" ]]; then
        test=$(kubectl get secret ${secret_name} -n ${namespace} -oname 2> /dev/null || true)
        if [[ -n "${test}" ]]; then
            echo "deleting existing secret ${secret_name}"
            kubectl delete secret ${secret_name} -n ${namespace} 1> /dev/null
        fi
        echo "installing registry secret ${secret_name} in namespace ${namespace}"
        kubectl create secret --namespace ${namespace} docker-registry ${secret_name} \
            --docker-server   "${registry_host}" \
            --docker-username "${registry_username}" \
            --docker-password "${registry_password}"
    fi
}

function try_login_ghcr () {
    local github_user=${1:-${GITHUB_USER}}
    # altering variable using parameter expansion ",," in bash to be all lowercase since repo URLs must be all lowercase
    local github_user=${github_user,,}
    local github_token=${2:-${GITHUB_TOKEN}}

    registry_hostname=ghcr.io

    if [[ -z "${github_token}" || -z "${github_user}" ]]; then
        echo "WARNING: GitHub token and/or username not provided"
        echo "         Image push will fail if you have not logged in to ghcr.io with \`docker login\`"
    else
        echo "INFO: signing in to registry ${registry_hostname} as ${github_user}"
        echo "${github_token}" | docker login --username "${github_user}" --password-stdin ${registry_hostname} &> /dev/null
    fi
}

function label_ghcr_image () {
    local image_url=${1}
    local repo_path=${2}

    echo "FROM ${image_url}" | \
        docker build \
            --label "org.opencontainers.image.source=https://github.com/${repo_path}" \
            --tag "${image_url}" \
            -
}
