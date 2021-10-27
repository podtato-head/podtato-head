#!/usr/bin/env bash

declare -a TAGS=("v1" "v2" "v3" "v4")

for TAG in "${TAGS[@]}"
do
  echo ""
  echo "------------------"
	echo "--> building version $TAG"
	echo "------------------"

  echo ""
	echo "--> podtato-head main"
  if ! docker build -f podtato-services/main/docker/Dockerfile ./podtato-services/main --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-main:"${TAG}"; then
    echo "podtato-head main build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head hat"
  if ! docker build -f podtato-services/hats/docker/Dockerfile ./podtato-services/hats --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-hats:"${TAG}"; then
    echo "podtato-head hat build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head left-leg"
  if ! docker build -f podtato-services/left-leg/docker/Dockerfile ./podtato-services/left-leg --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-left-leg:"${TAG}"; then
    echo "podtato-head left-leg build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head left-arm"
  if ! docker build -f podtato-services/left-arm/docker/Dockerfile ./podtato-services/left-arm --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-left-arm:"${TAG}"; then
    echo "podtato-head left-arm build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head right-leg"
  if ! docker build -f podtato-services/right-leg/docker/Dockerfile ./podtato-services/right-leg --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-right-leg:"${TAG}"; then
    echo "podtato-head right-leg build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head right-arm"
  if ! docker build -f podtato-services/right-arm/docker/Dockerfile ./podtato-services/right-arm --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-right-arm:"${TAG}"; then
    echo "podtato-head right-arm build failed with rc $?"
    exit 1
  fi

  if [[ ! -z ${PUSH} ]]; then
    echo ""
    echo "--> pushing images for tag $TAG"
    (docker push "${REPOSITORY}"/podtato-main:"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-hats:"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-left-leg:"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-left-arm:"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-right-leg:"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-right-arm:"${TAG}") || exit 1
  fi

done
