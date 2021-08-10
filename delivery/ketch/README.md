![Ketch](https://i.imgur.com/TVe46Dm.png)

# Ketch

**[TheKetch.io](https://theketch.io/)**

Ketch makes it extremely easy to deploy and manage applications on Kubernetes using a simple command-line interface. No Kubernetes object YAML is required!

## Index

* [Setup](#setup)
* [Managing node pools](#managing-node-pools)
* [Creating applications](#creating-applications)
* [Deploying applications](#deploying-applications)

## Setup

You can use any Kubernetes cluster to run Ketch. An example of a local cluster using [k3d](https://k3d.io/) is as follows.

*NOTE: Please make sure that you cloned this repository and that you are inside the same directory as this README.*

```bash
k3d cluster create --config k3d.yaml
```

Please go to the [Ketch Releases](https://github.com/shipa-corp/ketch/releases) page to download the CLI for your OS.

Ketch assumes that Cert Manager, Ingress, and Ketch controller are installed.

Install Cert Manager, Istio, Cluster Issuer, and Ketch Controller:

**NOTE: If you do not already have `istioctl`, the binary can be downloaded from the [releases](https://github.com/istio/istio/releases).*

```bash
kubectl apply \
    --filename https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.yaml \
    --validate=false

istioctl install --skip-confirmation

kubectl apply --filename cluster-issuer.yaml

kubectl apply --filename https://github.com/shipa-corp/ketch/releases/download/v0.2.1/ketch-controller.yaml
```

Retrieve the IP of the load balancer that will be used to auto-generate addresses of the applications.

Please execute the command that follows if you are using a **local k3d cluster** (as in the example above).

```bash
export INGRESS_IP=127.0.0.1
```

Otherwise, if you are using a **remove cluster**, please execute the command that follows.

*NOTE: Some Kubernetes clusters (e.g., AWS EKS) might be providing `hostname` instead of the `ip`. If that's the case, please modify the command that follows accordingly.*

```bash
export INGRESS_IP=$(kubectl --namespace istio-system get service istio-ingressgateway --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

## Managing node pools

Ketch implements the concept of pools, which Platform Engineers and DevOps can use to isolate workloads from different teams, resources assigned to applications, and more. You can add multiple pools to the same cluster.

The command that follows creates a Node Pool called `dev`.

```bash
ketch pool add dev --namespace dev --ingress-service-endpoint $INGRESS_IP --ingress-type istio
```

## Creating applications

Ketch makes a distinction between creating and deploying applications.

Creation of an application results in a setup of the framework on a specific pool which can be used to deploy your code in.

```bash
ketch app create podtato --pool dev
```

## Deploying applications

Ketch can deploy an application through a pre-built container image or directly from code. The example that follows uses the former method.

```bash
ketch app deploy podtato --image ghcr.io/podtato-head/podtatoserver:v0.1.1
```

We can list all the applications created through Ketch.

```bash
ketch app list
```

Please open the address available in the output.

Additional addresses can be added to the application with the command that follows.

```bash
# Replace `[...]` with the address through which you'd like to access the application
ketch cname add [...] --app podtato
```
