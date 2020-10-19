#!/usr/bin/env bash

PROJECT="pod-tato-head"
IMAGE="aloisreitbauer/hello-server"

case "$1" in
  "create-project")
    echo "Creating keptn project $PROJECT"
    keptn create project pod-tato-head --shipyard=./shipyard.yaml
    ;;
  "onboard-service")
    echo "Onboarding keptn service helloservice in project ${PROJECT}"
    keptn onboard service helloservice --project="${PROJECT}" --chart=helm-charts/helloserver
    ;;
  "deploy-service")
    echo "Deploying keptn service helloservice in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v0.1.1
    ;;
  "upgrade-service")
    echo "Upgrading keptn service helloservice in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v0.1.2
    ;;
esac