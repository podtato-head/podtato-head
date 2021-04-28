![Ketch](https://i.imgur.com/TVe46Dm.png)

# Ketch

**[TheKetch.io](https://theketch.io/)**

Ketch makes it extremely easy to deploy and manage applications on Kubernetes using a simple command-line interface. No Kubernetes object YAML is required!

TODO: Index

## Requirements

* A Kubernetes cluster
* `ketch` CLI: https://github.com/shipa-corp/ketch/releases)

## Setup

Install Cert Manager:

```bash
kubectl apply \
    --filename https://github.com/jetstack/cert-manager/releases/download/v1.0.3/cert-manager.yaml \
    --validate=false
```

Install Traefik (it could also be Istio):

```bash
helm repo add traefik https://helm.traefik.io/traefik

helm repo update

helm upgrade --install traefik traefik/traefik --namespace traefik --create-namespace 
```

Install Cluster Issuer:

```bash
echo "apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: le 
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: my-account-key
    solvers:
    - http01:
       ingress:
         class: traefik" \
    | kubectl apply --filename -
```

Install Ketch Controller

```bash
kubectl apply --filename https://github.com/shipa-corp/ketch/releases/download/v0.2.1/ketch-controller.yaml
```

Retrieve the IP of the load balancer that will be used to auto-generate addresses of the applications.

*NOTE: Some Kubernetes clusters (e.g., AWS EKS) might be providing `hostname` instead of the `ip`. If that's the case, please modify the command that follows accordingly.*

```bash
export BASE_HOST=$(kubectl --namespace traefik get service traefik --output jsonpath="{.status.loadBalancer.ingress[0].ip}")
```

## Managing node pools

Ketch implements the concept of pools, which Platform Engineers and DevOps can use to isolate workloads from different teams, resources assigned to applications, and more. You can add multiple pools to the same cluster.

The command that follows creates a Node Pool called `dev`.

```bash
ketch pool add dev --namespace dev --ingress-service-endpoint $BASE_HOST --ingress-type traefik
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

Please copy the address and open it in your favorite browser to confirm that it is working correctly.
