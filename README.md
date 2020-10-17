# Demo project for showcasing cloud-native application delivery use cases

This project is it's very early stages, so please - be kind.

## What you are getting

This project consists of the smallest possible application to demo cloud native
application delivery. It - for sure - will grow over time. Right now this is
what you are getting:

* A single file go server that says "Hello world"
* A multi-stage build docker file to build a container
* A manifest ot create a Kubernetes service and deployment. 
* A helm chart for the service and the deployment.
* Three container images showing different versions
    * aloisreitbauer/hello-server:v0.1.0
    * aloisreitbauer/hello-server:v0.1.1
    * aloisreitbauer/hello-server:v0.1.2 

## Scenarios and Use Cases you can test with this repository

This list is supposed to grow over time. Here is the list of use cases, that are
currently supported:

* Direct deployment via a manifest
* Direct deployment via a Helm chart
* GitOps based deployment using ArgoCd

Use cases supported going foward:

* GitOps based deployment using Flux
* Blue/Green releases via Argo Rollouts
* CNAB air gapped deployment
* _<feel free to create issues for use cases you are interested in>_
