#! /usr/bin/env bash

## to temporarily install binaries (works as non-root): `source ./requirements.sh`
## to permanently install binaries (make require sudo): `./requirements.sh /path/to/install/dir`

install_dir=${1}

if [[ -z "${install_dir}" ]]; then
    echo "INFO: installing requirements to temp dir and adding that to PATH"
    install_dir=$(mktemp -d)
    export PATH="${install_dir}:${PATH}"
fi

## trivy
echo ""
echo "installing trivy to ${install_dir}"
trivy_version=v0.21.1
curl -sSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
    sh -s -- -b "${install_dir}" "${trivy_version}"
trivy --version

## cosign
echo ""
echo "installing cosign to ${install_dir}"
cosign_version=v1.3.1
curl -sSL -o "${install_dir}/cosign" https://storage.googleapis.com/cosign-releases/${cosign_version}/cosign-linux-amd64
chmod +x "${install_dir}/cosign"
cosign version
