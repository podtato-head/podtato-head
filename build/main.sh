#!/usr/bin/env bash

declare -a TAGS=("0.1.0" "0.1.1" "0.1.2")
for TAG in "${TAGS[@]}"
do
  docker build -f podtato-services/podtato-main/docker/DockerfileV"${TAG}" ./podtato-services/podtato-main --tag "${REPOSITORY}"/podtato-main:v"${TAG}" && \
  docker push "${REPOSITORY}"/podtato-main:v"${TAG}"
done
