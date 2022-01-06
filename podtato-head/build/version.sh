#! /usr/bin/env bash

# To specify a custom version set a global ${VERSION} variable before calling
# this function. You will likely need to pass that same ${VERSION} variable to
# downstream examples to use to parameterize image tags.

# NOTE: Test images are pushed to ghcr.io/${github_user}/podtato-head/...
#       Release images are pushed to ghcr.io/podtato-head/...

# We get the latest tag, strip it of prefixes and suffixes, and increment the
# patch (x.y.Z) version by 1 by default.
# If ${INCREMENT_MAJOR} or ${INCREMENT_MINOR} are set we increment those instead.

function version_to_use () {
    current_release_commit=$(git --no-pager rev-list --tags --max-count=1)
    current_release_version="$(git describe --tags ${current_release_commit})"

    bare_version=$(echo "${current_release_version}" | \
        sed 's/^v//' | \
        sed 's/-.*$//')
    ver_array=($(echo "${bare_version}" | tr '.' ' '))
    if [[ ${INCREMENT_MAJOR} ]]; then
        ver_array[0]=$((${ver_array[0]} + 1))
    elif [[ ${INCREMENT_MINOR} ]]; then
        ver_array[1]=$((${ver_array[1]} + 1))
    else
        ver_array[2]=$((${ver_array[2]} + 1))
    fi
    IFS='.'
    version=${VERSION:-$(echo "${ver_array[*]}")}
    unset IFS

    echo "${version}"
}