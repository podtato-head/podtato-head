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
trivy_version=v0.22.0
curl -sSL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
    sh -s -- -b "${install_dir}" "${trivy_version}"
trivy --version

## cosign
echo ""
echo "installing cosign to ${install_dir}"
cosign_version=v2.2.0
# give me the arch
case "$(uname -m)" in
    "x86_64")
        arch="amd64"
        ;;
    "armv7l")
        arch="arm"
        ;;
    "aarch64")
        arch="arm64"
        ;;
    *)
        echo "ERROR: unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac
# give me the OS
case "$(uname -s)" in
    "Linux")
        os="linux"
        ;;
    "Darwin")
        os="darwin"
        ;;
    *)
        echo "ERROR: unsupported OS: $(uname -s)"
        exit 1
        ;;
esac
curl -sSL -o "${install_dir}/cosign" https://github.com/sigstore/cosign/releases/download/${cosign_version}/cosign-${os}-${arch}
chmod +x "${install_dir}/cosign"
cosign version

## skopeo
# https://github.com/containers/skopeo/blob/main/install.md
echo ""
eval $(cat /etc/os-release)
case "${NAME}" in
  "*Debian*" | "*Ubuntu*")
    sudo apt install skopeo
    ;;
  "*Red Hat*" | "*Fedora*")
    sudo dnf -y install skopeo
    ;;
  "*Darwin*")
    sudo brew install skopeo
    ;;
  *)
    sudo apt install skopeo
    ;;
esac
