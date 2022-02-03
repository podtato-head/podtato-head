## for cosign: cosign must be installed, COSIGN_PASSWORD and COSIGN_KEY_PATH must be set
## for trivy:  trivy must be installed

function build_image () {
    local context_dir=${1}
    local relative_path_to_dockerfile=${2}
    local image_name=${3}
    local image_tag=${4}
    local registry_user=${5:-podtato-head}
    local push_too=${6:-"${PUSH_TO_REGISTRY}"}

    echo "INFO: building image ${image_name}:${image_tag}"
    echo "INFO: with context dir ${context_dir} and file ${relative_path_to_dockerfile}"

    docker build ${context_dir} \
        --tag "${image_name}:${image_tag}" \
        --build-arg "GITHUB_USER=${registry_user}" \
        --file "${context_dir}/${relative_path_to_dockerfile}"

    if [[ -n "${push_too}" ]]; then
        echo "INFO: pushing image ${image_name}:${image_tag}"
        docker push "${image_name}:${image_tag}"
    fi

    sign_images=$(if type -P cosign > /dev/null; then echo 1; else echo 0; fi)
    if [[ ${sign_images} == 1 && -n "${COSIGN_PASSWORD}" && -n "${COSIGN_KEY_PATH}" ]]; then
        echo "INFO: signing ${image_name}:${image_tag} using cosign version" \
            $(cosign version --json | jq -r '.GitVersion')
        cosign sign --key "${COSIGN_KEY_PATH}" \
            --annotations version=${image_tag} \
            "${image_name}:${image_tag}"
    fi

    scan_images=$(if type -P trivy > /dev/null; then echo 1; else echo 0; fi)
    if [[ ${scan_images} == 1 ]]; then
        echo "INFO: scanning ${image_name} using trivy version" \
            $(trivy --version | head -1 | sed -E 's/^Version: (.*)$/\1/')
        trivy image \
            --format table \
            --severity "HIGH,CRITICAL" \
            --no-progress \
                ${image_name}
    fi
}
