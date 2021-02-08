#!/usr/bin/env bash

REPOSITORY="ghcr.io/podtato-head"

TAG="0.1.0"

docker build -f ./DockerfileV"${TAG}" . --tag "${REPOSITORY}"/hello-server:v"${TAG}"
docker push "${REPOSITORY}"/hello-server:v"${TAG}"  

TAG="0.1.1"

docker build -f ./DockerfileV"${TAG}" . --tag "${REPOSITORY}"/hello-server:v"${TAG}"
docker push "${REPOSITORY}"/hello-server:v"${TAG}"  

TAG="0.1.2"

docker build -f ./DockerfileV"${TAG}" . --tag "${REPOSITORY}"/hello-server:v"${TAG}"
docker push "${REPOSITORY}"/hello-server:v"${TAG}"  