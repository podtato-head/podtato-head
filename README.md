# Project _pod_ tato Head

Podtato-head demonstrates cloud-native application delivery scenarios using many
different tools and services. It is intended to help application delivery
support teams test and decide which mechanism(s) to use.

![podtato-head](/podtato-head/pkg/assets/images/podtato-head.png)

## What is it?

The project comprises a set of microservices, and a set of examples
demonstrating how to deliver them.

### Services

Several communicating services are defined in this project with as little
additional logic as possible to enable you to focus on the delivery mechanisms
themselves.

The entry point to these services is defined in `cmd/entry`. A base for each of
the downstream services is defined in `cmd/parts`. An image for each part - hat,
each arm and each leg - can be built with `make build-images` or `make
pull-images`.

To test the built images in a cluster, run `make test-services`, which spins up
a cluster using `kind` and deploys the services with `kubectl` and YAML
manifests.

NOTE: In order to push and pull images from GitHub's registry, you must set up
your environment as follows:

1. Fork the podtato-head repo (you cannot push images to the main repo)
1. Create a personal access token with `packages:write` permissions
1. Set an env var `GITHUB_TOKEN` to the value of the token from the previous
   step, e.g. `export GITHUB_TOKEN=<token_value>`
1. Set an env var `GITHUB_USER` to your GitHub username, e.g. `export
   GITHUB_USER=<user_name>`

### Delivery

Within the `delivery` directory this set of services and images is delivered in
many different ways to enable you to compare and contrast them.  Each delivery
mechanism yields the same end result: an API service which communicates with
other API services and returns HTML.

## Delivery scenarios

Following is the list of scenarios currently implemented. "Single" deployments
mean the action effects the state of the resources only once at the time of
invocation. "GitOps" deployments mean the action maintains (reconciles) the
desired state periodically.

* [Single deployment via Kubectl](/delivery/kubectl/README.md)
* [Single deployment via Helm](/delivery/chart/README.md)
* [Single deployment via Kustomize](/delivery/kustomize/README.md)
* [Single deployment via Ketch](/delivery/ketch/README.md)
* [Single deployment via Kapp](/delivery/kapp/README.md)
* [GitOps deployment via Flux](/delivery/flux/README.md)
* [GitOps deployment via ArgoCd](/delivery/ArgoCD/README.md)
* [Single canary deployment via Argo Rollouts](/delivery/rollout/README.md)
* [Helm-based operator deployment](/delivery/podtato-operator/README.md)
* [Multi-Stage delivery with Keptn](/delivery/keptn/README.md)
* [CNAB with Porter air-gapped deployment](/delivery/CNABwithPorter/README.md)
* [GitOps deployment via KubeVela](/delivery/KubeVela/README.md)
* [GitOps deployment via Gimlet CLI](/delivery/gimlet/README.md)

## Cluster environment

You can use any K8S cluster to run this project.  If you do not have a K8S
cluster at your disposal, you can quickly get a local one with
[kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

_NOTE_: If you use a cluster with no access to external LoadBalancer (like a
`kind` cluster), you may have to replace `type: LoadBalancer` by `type:
ClusterIP` (or `type: NodePort`) in all files declaring a service definition :

```bash
# Update service type in all K8S manifests
find delivery -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/type: LoadBalancer/type: ClusterIP/g'
# Update service type in all Helm values
find delivery -type f -name "*.yaml" -print0 | xargs -0 sed -i 's/serviceType: LoadBalancer/serviceType: ClusterIP/g'
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See [LICENSE](LICENSE).