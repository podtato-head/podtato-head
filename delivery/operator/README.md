# Deliver with an operator

Here's how to deliver podtato-head using the [Operator
Framework](https://operatorframework.io) to create and provision a Helm chart-based operator built
with the [Operator SDK](https://sdk.operatorframework.io). [Operator Lifecycle
Manager](https://olm.operatorframework.io) is used to deploy the operator.

If you just want to run the tests and review generated artifacts:

1. Put a GitHub username and token with packages:write permissions in your clone of the repo's .env file.
1. Run `WAIT_FOR_DELETE=1 ./test.sh`. Press Ctrl+C at the wait point to retain the deployment.
1. Explore the generated operator code in `./test/work`.

## Prerequisites

You will need to install [Operator SDK](https://sdk.operatorframework.io/) to
your workstation and [Operator Lifecycle
Manager](https://olm.operatorframework.io/) (OLM) to your Kubernetes cluster.

1. Install `operator-sdk` CLI ([official instructions](https://sdk.operatorframework.io/docs/installation/))
1. Install OLM operator ([official instructions](https://olm.operatorframework.io/docs/getting-started/))
   
An example follows. You may also want to review the test script at
[./test/install-operator-framework.sh](./test/install-operator-framework.sh).

```bash
OSDK_VERSION=1.16.0
DEST_DIR=/usr/local/bin
OS=linux
ARCH=amd64

curl -L -o "${DEST_DIR}/operator-sdk" \
    https://github.com/operator-framework/operator-sdk/releases/download/v${OSDK_VERSION}/operator-sdk_${OS}_${ARCH}
chmod +x "${DEST_DIR}/operator-sdk"

operator-sdk version
operator-sdk olm install
operator-sdk olm status
```

## Deliver

Deliver podtato-head by creating an operator to manage "PodtatoHeadApp"
resources, then declaring such a resource per the following instructions. You
may also want to review the test script at
[./test/build-and-push-operator.sh](./test/build-and-push-operator.sh).

### Build a Helm chart-based operator

In an empty directory init a new Helm operator from the podtato-head chart as follows.

```bash
chart_dir=./delivery/chart
# expand relative path so it works from other dirs
chart_dir=$(cd ${chart_dir} && pwd)

work_dir=./work
mkdir -p ${work_dir}
cd ${work_dir}

operator-sdk init --plugins 'helm.sdk.operatorframework.io/v1' --project-version=3 \
    --project-name 'podtato-head-operator' \
    --domain=podtato-head.io \
    --group=apps \
    --version=v1alpha1 \
    --kind=PodtatoHeadApp \
    --helm-chart=${chart_dir}
```

Now build and push the operator image, the operator bundle, and a catalog which
includes the bundle as follows. We use GitHub's container registry `ghcr.io`;
you will need to be signed in to push images. Sign in by getting a personal
access token with `packages:write` permissions and running the following commands.

```bash
github_user=
github_token=

echo "${github_token}" | docker login --username=${github_user} --password-stdin ghcr.io

export IMAGE_TAG_BASE=ghcr.io/${github_user,,}/podtato-head/operator
export IMG=${IMAGE_TAG_BASE}:latest

make docker-build docker-push
make bundle bundle-build bundle-push
make catalog-build catalog-push
```

### Deploy the operator via catalog and subscription

To deploy the operator we'll bundle and deploy a catalog that includes it and
then subscribe to our package, as follows. You may also want to review the test
script at [./test/deploy-operator.sh](./test/deploy-operator.sh).

First deploy the catalog source to the OLM namespace:

```bash
image_base_url=ghcr.io/${github_user}/podtato-head/operator
operator_version=0.0.1

kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
    name: podtato-head-catalog
    namespace: olm
spec:
    sourceType: grpc
    image: ${image_base_url}-catalog:v${operator_version}
    secrets:
      - ghcr
    displayName: podtato-head-catalog
    publisher: podtato-head
    updateStrategy:
        registryPoll:
            interval: 10m
EOF
```

Next declare a subscription to the podtato-head-operator in the `operators` namespace:

```bash
operator_version=0.0.1

kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: podtato-head-operator
    namespace: operators
spec:
    channel: alpha
    installPlanApproval: Automatic
    name: podtato-head-operator
    source: podtato-head-catalog
    sourceNamespace: olm
    startingCSV: podtato-head-operator.v${operator_version}
EOF
```

The `Subscription` triggers generation of an `InstallPlan` to install the
components listed in the referenced `ClusterServiceVersion`, such as
Deployments, Services, Service Accounts and other resources.

Watch for the successful provisioning of the operator deployment:

```bash
kubectl get deployments --namespace operators --watch
kubectl get clusterserviceversion --namespace operators --watch
```

### Deploy a PodtatoHeadApp resource

With the operator installed in our cluster, we may declare a PodtatoHeadApp
resource in any namespace and the operator will deploy it for us, as follows. See
[./test/install-podtatoheadapp.sh](./test/install-podtatoheadapp.sh) too.

Note that the spec for this custom resource is based on our chart's values.yaml
file.

```bash
kubectl apply -f - <<EOF
apiVersion: apps.podtato-head.io/v1alpha1
kind: PodtatoHeadApp
metadata:
  name: podtato-head-app-01
  namespace: default
spec:
  entry:
    serviceType: NodePort
  images:
    repositoryDirname: ghcr.io/${github_user}/podtato-head
EOF
```

### Deploy without catalog and subscription

Instead of using catalogs and subscriptions you may install the
operator's controller and managed CRDs directly as follows:

```bash
export IMAGE_TAG_BASE=ghcr.io/${github_user}/podtato-head/operator
export IMG=${IMAGE_TAG_BASE}:latest

# build and push operator controller image
make docker-build docker-push

# install managed CRDs
make install

# deploy operator controller
make deploy

# install managed resources
kustomize build config/samples | kubectl apply -f -

# delete managed resources
kustomize build config/samples | kubectl delete -f -

# delete operator
make undeploy

# delete CRD
make uninstall
```

## Test

Verify deployment:

```bash
kubectl get podtatoheadapps
kubectl get deployments
kubectl get pods
```

### Test the API endpoint

To connect to the API you'll first need to determine the correct address and
port.

If using a LoadBalancer-type service, get the IP address of the load balancer
and use port 9000:

```
ADDR=$(kubectl get service podtato-head-entry -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=9000
```

If using a NodePort-type service, get the address of a node and the service's
NodePort as follows:

```
ADDR=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
PORT=$(kubectl get services podtato-head-entry -ojsonpath='{.spec.ports[0].nodePort}')
```

If using a ClusterIP-type service, run `kubectl port-forward` in the background
and connect through that:

> NOTE: Find and kill the port-forward process afterwards using `ps` and `kill`.

```
kubectl port-forward service/podtato-head-entry 9000:9000 &
ADDR=127.0.0.1
PORT=9000
```

Now test the API itself with curl and/or a browser:

```
curl http://${ADDR}:${PORT}/
xdg-open http://${ADDR}:${PORT}/
```

## Update

// TODO

## Rollback

// TODO

## Purge

Uninstall everything using the commands in [./test/teardown.sh](./test/teardown.sh).
