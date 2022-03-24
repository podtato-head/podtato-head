#! /usr/bin/env bash

# Installs Operator SDK to the current workstation, then installs Operator
# Lifecycle Manager (OLM) to the current cluster context.

# env vars:
# DEST_DIR

### install operator-sdk
if ! type operator-sdk &> /dev/null; then
    if [[ -n "${DEST_DIR}" ]]; then
        dest_dir=${DEST_DIR}
    else
        dest_dir=$(mktemp -d)
    fi
    export PATH=${dest_dir}:${PATH}

    echo "downloading and installing operator-sdk to ${dest_dir}"
    osdk_version=1.16.0
    OS=linux
    ARCH=amd64
    curl -sSL -o "${dest_dir}/operator-sdk" \
        https://github.com/operator-framework/operator-sdk/releases/download/v${osdk_version}/operator-sdk_${OS}_${ARCH}
    chmod +x "${dest_dir}/operator-sdk"
fi

echo "operator-sdk version"
operator-sdk version
### /end install operator-sdk

### install OLM
echo "operator-sdk olm status"
{
    set +e
    operator-sdk olm status &> /dev/null
    status_result=$?
}

if [[ ${status_result} != 0 ]]; then
    echo "\`operator-sdk olm status\` failed with result ${status_result}"
    echo "assuming OLM is not installed, attempting to install it"
    operator-sdk olm install
fi
### /end install OLM