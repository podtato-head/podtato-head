#! /usr/bin/env bash

# To specify a custom version set a global ${IMAGE_VERSION} variable before calling
# this function. You will likely need to pass that same ${IMAGE_VERSION} variable to
# downstream examples to use to parameterize image tags.

# NOTE: Test images are pushed to ghcr.io/${github_user}/podtato-head/...
#       Release images are pushed to ghcr.io/podtato-head/...

# We get the latest tag, strip it of prefixes and suffixes, and increment the
# patch (x.y.Z) version by 1 by default.
# If ${INCREMENT_MAJOR} or ${INCREMENT_MINOR} are set we increment those instead.

function version_to_use () {
    if [[ -n "${IMAGE_VERSION}" ]]; then
        echo "${IMAGE_VERSION}"
        return
    fi

    local github_user=${1:-${GITHUB_USER}}

    >&2 echo "INFO: dynamically determining version"
    last_image_tag=$(skopeo list-tags docker://ghcr.io/${github_user:+${github_user}/}podtato-head/entry | \
        jq -r '.Tags[]' | grep -P '^[\d\.]*$' | sort | tail -1)
    >&2 echo "INFO: last_image_tag: ${last_image_tag}"
    bare_version=$(echo "${last_image_tag}" | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')
    >&2 echo "INFO: bare_version: ${bare_version}"

    ver_array=($(echo "${bare_version}" | tr '.' ' '))
    if [[ ${INCREMENT_MAJOR} ]]; then
        ver_array[0]=$((${ver_array[0]} + 1))
    elif [[ ${INCREMENT_MINOR} ]]; then
        ver_array[1]=$((${ver_array[1]} + 1))
    elif [[ -z "${NO_INCREMENT}" ]]; then
        ver_array[2]=$((${ver_array[2]} + 1))
    fi
    IFS='.'
    version=$(echo "${ver_array[*]}")
    unset IFS

    >&2 echo "INFO: returning version: ${bare_version}"
    echo "${version}"
}

version_to_use
