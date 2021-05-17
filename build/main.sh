#!/usr/bin/env bash

declare -a TAGS=("0.1.0" "0.1.1" "0.1.2" "0.1.3" "0.1.4")

for TAG in "${TAGS[@]}"
do
  echo ""
  echo "------------------"
	echo "--> building version $TAG"
	echo "------------------"

  echo ""
	echo "--> podtato-head main"
  if ! docker build -f podtato-services/podtato-main/docker/Dockerfile ./podtato-services/podtato-main --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-main:v"${TAG}"; then
    echo "podtato-head main build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head hat"
  if ! docker build -f podtato-services/hats/docker/Dockerfile ./podtato-services/hats --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-hats:v"${TAG}"; then
    echo "podtato-head hat build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head left-leg"
  if ! docker build -f podtato-services/left-leg/docker/Dockerfile ./podtato-services/left-leg --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-left-leg:v"${TAG}"; then
    echo "podtato-head left-leg build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head left-arm"
  if ! docker build -f podtato-services/left-arm/docker/Dockerfile ./podtato-services/left-arm --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-left-arm:v"${TAG}"; then
    echo "podtato-head left-arm build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head right-leg"
  if ! docker build -f podtato-services/right-leg/docker/Dockerfile ./podtato-services/right-leg --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-right-leg:v"${TAG}"; then
    echo "podtato-head right-leg build failed with rc $?"
    exit 1
  fi

  echo ""
  echo "--> podtato-head right-arm"
  if ! docker build -f podtato-services/right-arm/docker/Dockerfile ./podtato-services/right-arm --build-arg VERSION="${TAG}" --tag "${REPOSITORY}"/podtato-right-arm:v"${TAG}"; then
    echo "podtato-head right-arm build failed with rc $?"
    exit 1
  fi

  if [[ ! -z ${PUSH} ]]; then
    echo ""
    echo "--> pushing images for tag $TAG"
    (docker push "${REPOSITORY}"/podtato-main:v"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-hats:v"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-left-leg:v"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-left-arm:v"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-right-leg:v"${TAG}" && \
    docker push "${REPOSITORY}"/podtato-right-arm:v"${TAG}") || exit 1
  fi

done
