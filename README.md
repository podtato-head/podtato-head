# Project _pod_ tato Head - A demo project for showcasing cloud-native application delivery use cases using different tools for various use cases

![podtatohead](/images/podtatoHead.png)

This project is in it's very early stages, so please - be kind.

## What you are getting

This project consists of the smallest possible application to demo cloud native
application delivery. It - for sure - will grow over time. Right now you get the following components:

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

* [Direct deployment via a manifest](/docs/plainManifest.md)
* [Direct deployment via a Helm chart](/docs/helmChart.md)
* [GitOps-based deployment using Flux](/docs/flux.md)
* [GitOps-based deployment using ArgoCd](/docs/gitOpsArgoCD.md)
* [Canary releases via Argo Rollouts](/docs/rollouts.md)
* [Helm-based operator deployment](/docs/helmOperator.md) 
* [Multi-Stage delivery with Keptn](/docs/keptnDelivery.md)
* [CNAB with Porter air-gapped deployment](/docs/cnabWithPorter.md) (_work in progress_)

Use cases supported going foward:


* _feel free to create issues for use cases you are interested in_
