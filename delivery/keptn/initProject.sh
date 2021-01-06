#!/usr/bin/env bash

PROJECT="pod-tato-head"
IMAGE="aloisreitbauer/hello-server"
VERSION="$2"

case "$1" in
  "create-project")
    echo "Creating keptn project $PROJECT"
    echo keptn create project "${PROJECT}" --shipyard=./shipyard.yaml   
    keptn create project "${PROJECT}" --shipyard=./shipyard.yaml
    ;;
  "onboard-service")
    echo "Onboarding keptn service helloservice in project ${PROJECT}"
    keptn onboard service helloservice --project="${PROJECT}" --chart=helm-charts/helloserver
    ;;
  "first-deploy-service")
    echo "Deploying keptn service helloservice in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v0.1.1
    ;;
  "deploy-service")
    echo "Deploying keptn service helloservice in project ${PROJECT}"
    echo keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v"${VERSION}"
    keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v"${VERSION}"
    ;;    
  "upgrade-service")
    echo "Upgrading keptn service helloservice in project ${PROJECT}"
    keptn send event new-artifact --project="${PROJECT}" --service=helloservice --image="${IMAGE}" --tag=v0.1.2
    ;;
esac