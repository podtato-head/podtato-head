#!/usr/bin/env bash

docker build -f podtato-services/hats/docker/Dockerfile ./podtato-services/hats --tag "${REPOSITORY}"/podtato-hats:"${TAG}" && \
docker push "${REPOSITORY}"/podtato-hats:"${TAG}"

docker build -f podtato-services/left-leg/docker/Dockerfile ./podtato-services/left-leg --tag "${REPOSITORY}"/podtato-left-leg:"${TAG}" && \
docker push "${REPOSITORY}"/podtato-left-leg:"${TAG}"

docker build -f podtato-services/left-arm/docker/Dockerfile ./podtato-services/left-arm --tag "${REPOSITORY}"/podtato-left-arm:"${TAG}" && \
docker push "${REPOSITORY}"/podtato-left-arm:"${TAG}"

docker build -f podtato-services/right-leg/docker/Dockerfile ./podtato-services/right-leg --tag "${REPOSITORY}"/podtato-right-leg:"${TAG}" && \
docker push "${REPOSITORY}"/podtato-right-leg:"${TAG}"

docker build -f podtato-services/right-arm/docker/Dockerfile ./podtato-services/right-arm --tag "${REPOSITORY}"/podtato-right-arm:"${TAG}" && \
docker push "${REPOSITORY}"/podtato-right-arm:"${TAG}"