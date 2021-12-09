#! /usr/bin/env bash

# Default to using previous version number for tests. This keeps things simple
# cause we expect downstream examples to specify the latest version, and per
# this new images will use existing examples for tests.
#
# Alternatively, to specify a custom version like `0.2.0-beta1` set a
# global ${VERSION} variable before calling this function. You will likely need
# to pass that same ${VERSION} variable to downstream examples to use to
# parameterize image tags.

# NOTE: Test images are pushed to ghcr.io/${github_user}/podtato-head/...
#       Release images are pushed to ghcr.io/podtato-head/...

# For release builds, we get the latest tag, strip it of prefixes and suffixes, and increment the _minor_ version by 1 (default).
# If ${INCREMENT_MAJOR} or ${INCREMENT_PATCH} are set we increment those instead.

function version_to_use () {
    # get last tagged commit
    current_release_commit=$(git --no-pager rev-list --tags --max-count=1)
    current_release_version="$(git describe --tags ${current_release_commit})"

    # default to using previous version number for tests
    if [[ -z "${RELEASE_BUILD}" ]]; then
        version=${VERSION:-${current_release_version}}
    else
        # release build, increment version
        bare_version=$(echo "${current_release_version}" | \
            sed 's/^v//' | \
            sed 's/-.*$//')
        ver_array=($(echo "${bare_version}" | tr '.' ' '))
        if [[ ${INCREMENT_MAJOR} ]]; then
            ver_array[0]=$((${ver_array[0]} + 1))
        elif [[ ${INCREMENT_PATCH} ]]; then
            ver_array[2]=$((${ver_array[2]} + 1))
        else
            ver_array[1]=$((${ver_array[1]} + 1))
        fi
        IFS='.'
        version=${VERSION:-$(echo "${ver_array[*]}")}
        unset IFS
    fi
    echo "${version}"
}