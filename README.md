# Project _pod_ tato Head


Podtato-head is a prototypical cloud-native application built to colorfully
demonstrate delivery scenarios using many different tools and services. It is
intended to help application delivery support teams test and decide which
of these to use.

<img src="podtato-head-microservices/pkg/assets/images/podtato-head.png" alt="Podtato Man" width="300" style="vertical-align: text-top;" />

The app comprises a set of microservices in `podtato-head-microservices` and a set of examples
demonstrating how to deliver them in `delivery`. The services are defined with
as little additional logic as possible to enable you to focus on the delivery
mechanisms themselves.

## Use it

Find the following set of delivery scenarios in the `delivery` directory.  Each
example scenario delivers the same end result: an API service which communicates
with other API services and returns HTML composed of all their responses.

Each delivery scenario includes a walkthrough (README.md) describing how to a)
install required supporting infrastructure; b) deliver podtato-head using the
infrastructure; and c) test that podtato-head is operating as expected.

Each delivery scenario also includes a test (test.sh) which automates the steps
described in the walkthrough.

### Delivery scenarios

"Single" deployment means the action effects the state of the resources _only
once_ at the time of invocation. "GitOps" deployments mean the action checks the
desired state periodically and reconciles it as needed.

* [Single deployment via Kubectl](/delivery/kubectl/README.md)
* [Single deployment via Helm](/delivery/chart/README.md)
* [Single deployment via Kustomize](/delivery/kustomize/README.md)
* [Single deployment via Ketch](/delivery/ketch/README.md)
* [Single deployment via Kapp](/delivery/kapp/README.md)
* [GitOps deployment via Flux](/delivery/flux/README.md)

The following scenarios have not yet been updated for the multi-service app:

* [GitOps deployment via ArgoCD](/delivery/ArgoCD/README.md)
* [Canary deployment via Argo Rollouts](/delivery/rollout/README.md)
* [Helm-based operator deployment](/delivery/podtato-operator/README.md)
* [Multi-Stage delivery with Keptn](/delivery/keptn/README.md)
* [CNAB with Porter air-gapped deployment](/delivery/CNABwithPorter/README.md)
* [GitOps deployment via KubeVela](/delivery/KubeVela/README.md)
* [GitOps deployment via Gimlet CLI](/delivery/gimlet/README.md)

## Extend it

Here's how to extend podtato-head for your own purposes or to contribute to the
shared repo.

### Services

podtato-head's services themselves are written in Go; entry points are in
`podtato-head-microservices/cmd`. The entry point to the app is defined in `cmd/entry` and a
base for each of the app's downstream services is defined in `cmd/parts`.

HTTP handlers and other shared functionality is defined in `podtato-head-microservices/pkg`.

### Build

Build an image for each part - entry, hat, each arm and each leg - with `make
build-images`.

> NOTE: To apply capabilities like image scans and signatures install required
  binaries first by running `[sudo] make install-requirements`.

### Publish

To test the built images you'll need to push them to a registry so that
Kubernetes can find them. `make push-microservices-images` can do this for
GitHub's container registry if you are authorized to push to the target repo (as
described next).

To push to your own fork of the podtato-head repo: 

1. [Fork podtato-head](https://github.com/podtato-head/podtato-head/fork) if you haven't already
1. [Create a personal access token (PAT)](https://github.com/settings/tokens/new) 
   with `write:packages` permissions and copy it
1. Set and export env vars `GITHUB_USER` to your GitHub username and `GITHUB_TOKEN` to the
   PAT, for example as follows:
   
   ```bash
   export GITHUB_USER=joshgav
   export GITHUB_TOKEN=goobledygook
   ```

> NOTE: You can also put env vars in the `.env` file in the repo's root; be sure
  not to include those updates in commits.

### Test

To test the built images as running services in a cluster, run `make
test-services`. This spins up a cluster using `kind` and deploys the services
using [the `kubectl` delivery scenario test](delivery/kubectl/test.sh).

These tests also rely on your GITHUB_USER and GITHUB_TOKEN env vars if
you're using your own fork.

NOTE: The `test-services` tasks isn't bound to the `push-images` task so that
they may be run separately. Make sure you run `make push-images` first.

## More info

All delivery scenarios are expected to run on any functional Kubernetes cluster
with cluster-admin access. That is, if you can run `kubectl get pods -n
kube-system` you should be able to run any of the tests.

If you don't have a local Kubernetes cluster for tests,
[kind](https://kind.sigs.k8s.io/) is one to consider.

**NOTE**: If you use a cluster without support for LoadBalancer-type services,
*which is typical for test clusters like kind, you may need to replace
*attributes which default to `LoadBalancer` with `NodePort` or `ClusterIP`.

For example:

```bash
# update type property in `service` resources
find delivery -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/type: LoadBalancer/type: NodePort/g'
# update custom serviceType property in Helm values file
find delivery -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/serviceType: LoadBalancer/serviceType: NodePort/g'
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).