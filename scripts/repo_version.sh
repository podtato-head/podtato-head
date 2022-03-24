#! /usr/bin/env bash

# To specify a custom version set a global ${REPO_VERSION} variable before calling
# this function.

# We get the latest tag, strip it of prefixes and suffixes, and increment the
# patch (x.y.Z) version by 1 by default.
# If ${INCREMENT_MAJOR} or ${INCREMENT_MINOR} are set we increment those instead.

function version_to_use () {
    if [[ -n "${REPO_VERSION}" ]]; then
        echo "${REPO_VERSION}"
        return
    fi

    >&2 echo "INFO: dynamically determining version"
    git fetch --tags
    current_release_commit=$(git --no-pager rev-list --tags --max-count=1)
    current_release_version="$(git describe --tags ${current_release_commit})"
    >&2 echo "INFO: last_image_tag: ${current_release_version}"
    bare_version=$(echo "${current_release_version}" | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')
    >&2 echo "INFO: bare_version: ${bare_version}"

    ver_array=($(echo "${bare_version}" | tr '.' ' '))
    if [[ ${INCREMENT_MAJOR} ]]; then
        ver_array[0]=$((${ver_array[0]} + 1))
    elif [[ ${INCREMENT_MINOR} ]]; then
        ver_array[1]=$((${ver_array[1]} + 1))
    else
        ver_array[2]=$((${ver_array[2]} + 1))
    fi
    IFS='.'
    version=$(echo "${ver_array[*]}")
    unset IFS

    >&2 echo "INFO: returning new version: ${bare_version}"
    echo "${version}"
}

version_to_use
