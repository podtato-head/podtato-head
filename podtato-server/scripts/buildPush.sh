#!/usr/bin/env bash

REPOSITORY="ghcr.io/podtato-head"
declare -a TAGS=("0.1.0" "0.1.1" "0.1.2")
for TAG in "${TAGS[@]}"
do
  docker build -f docker/DockerfileV"${TAG}" . --tag "${REPOSITORY}"/podtatoserver:v"${TAG}"
  docker push "${REPOSITORY}"/podtatoserver:v"${TAG}"
done