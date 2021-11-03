# Deliver with Flux

Here's how to deliver podtato-head using [flux](https://fluxcd.io). Flux deploys workloads as Helm releases or kustomize renderings.

## Prerequisites

1. Install `flux` CLI ([official instructions](https://toolkit.fluxcd.io/guides/installation/))
1. Install Flux's controllers in a cluster: `flux install --version=latest`

To update the Flux control plane later run `flux install` again.

> Alternatively, you may use the `flux bootstrap ...` command to install Flux
  and store its configuration in a git repo for ongoing reconciliation. To store
  the configuration in GitHub, first [get a GitHub personal access
  token](https://github.com/settings/tokens) and set it as the value of
  environment variable `GITHUB_TOKEN`. An example follows:

```bash
export GITHUB_TOKEN=<personal_access_token>
export GITHUB_USER=<github_username>
export GITHUB_REPO=flux-tests

flux bootstrap github \
    --owner="${GITHUB_USER}" \
    --repository="${GITHUB_REPO}" \
    --private=false \
    --personal

## verify
flux get all
```

## Deliver

You will fork the podtato-head repo and deliver it to your cluster.

### Connect to git repo

First, [fork the podtato-head repo](https://github.com/podtato-head/podtato-head/fork)
so that you can add an SSH key to it.

Next, connect this repo to Flux in your cluster by adding an SSH key pair and a
"source" resource as follows.

The `flux create secret git` command creates an SSH key pair for the specified
host and puts it into a named Kubernetes secret in Flux's management namespace
(by default `flux-system`). The command also outputs the public key, which
should be added to the repos "Deploy keys" in GitHub.

```bash
GITHUB_USER=<your_github_username>
flux create secret git podtato-flux-secret --url=ssh://git@github.com/${GITHUB_USER}/podtato-head
```

If you need to retrieve the public key later you can extract it from the secret as follows:

```bash
kubectl get secret podtato-flux-secret -n flux-system -ojson | jq -r '.data."identity.pub" | @base64d'
```

Use the public key as a Deploy key in your fork of the podtato-head repo. Browse to
this URL, replacing `<your_github_username>` with your GitHub username:
`https://github.com/<your_github_username>/podtato-head/settings/keys`. The page will appear as follows:

<img alt="GitHub SSH Deploy Keys" width="400px" src="./images/github-ssh-deploy-keys.png" />

```bash
ssh_public_key=$(kubectl get secret podtato-flux-secret -n flux-system -ojson | jq -r '.data."identity.pub" | @base64d')
gh api repos/${GITHUB_USER}/podtato-head/keys \
    -F title=podtato-flux-secret \
    -F "key=${ssh_public_key}"
```

Finally, create a git source that uses this secret:

```bash
GITHUB_USER=<your_github_username>
flux create source git podtato-flux-repo \
    --url=ssh://git@github.com/${GITHUB_USER}/podtato-head \
    --secret-ref podtato-flux-secret \
    --branch=main

# verify
flux get source git
```

### Process and apply

Now that a git source is available we will instruct Flux how to render and apply
it. Flux provides two rendering strategies - kustomizations and HelmReleases.
Both build on the git repo source created above.

#### HelmRelease

A HelmRelease composes a chart from a git or helm repository with values stored
in the resource and applies it to the cluster.

```bash
# the command only reads values from files so write this to one first
tmp_values_file=$(mktemp)
echo -e "main:\n  serviceType: NodePort" > ${tmp_values_file}

flux create helmrelease podtato-flux-release \
    --target-namespace=podtato-flux \
    --create-target-namespace \
    --source=GitRepository/podtato-flux-repo.flux-system \
    --chart=./delivery/chart \
    --values="${tmp_values_file}"

# verify
flux get helmrelease podtato-flux-release
```

#### Kustomization

A Kustomization is a render-and-apply strategy based on kustomize. Create a
kustomization as follows:

```bash
kubectl create namespace podtato-kflux
flux create kustomization podtato-flux-kustomization \
    --target-namespace podtato-kflux \
    --source=GitRepository/podtato-flux-repo.flux-system \
    --path=./delivery/kustomize/base \
    --prune=true

# verify
flux get kustomization podtato-kflux-kustomization
```

## Test

### Verify delivery

List all apps, get info or get logs for an app:

```bash
flux get all
flux get helmreleases
flux get kustomizations
flux get sources git
kubectl get pods -n podtato-flux
kubectl get pods -n podtato-kflux
```

### Test the API endpoint

To connect to the API you'll first need to determine the correct address and
port.

If using a LoadBalancer-type service for `main`, get the IP address of the load balancer
and use port 9000:

```
ADDR=$(kubectl get service podtato-main -n podtato-flux -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=9000
```

If using a NodePort-type service, get the address of a node and the service's
NodePort as follows:

```
ADDR=$(kubectl get nodes {NODE_NAME} -o jsonpath={.status.addresses[0].address})
PORT=$(kubectl get services podtato-main -n podtato-flux -ojsonpath='{.spec.ports[0].nodePort}')
```

If using a ClusterIP-type service, run `kubectl port-forward` in the background
and connect through that:

> NOTE: Find and kill the port-forward process afterwards using `ps` and `kill`.

```
# Choose below the IP address of your machine you want to use to access application 
ADDR=127.0.0.1
# Choose below the port of your machine you want to use to access application 
PORT=9000
kubectl port-forward --address ${ADDR} svc/podtato-main ${PORT}:9000 &
```

Now test the API itself with curl and/or a browser:

```
curl http://${ADDR}:${PORT}/
xdg-open http://${ADDR}:${PORT}/
```

## Update

Flux monitors the source git repo and redeploys the application when it detects
changes.

// TODO: describe how to update to a new version by modifying the git repo

## Rollback

// TODO: describe how to roll back to a previous version of the app

## Purge

```bash
flux delete --silent helmrelease podtato-flux-release
flux delete --silent kustomization podtato-flux-kustomization
flux delete --silent source git podtato-flux-repo
kubectl delete -n flux-system secret podtato-flux-secret
```