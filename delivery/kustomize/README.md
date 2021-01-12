# Kustomize

https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/

*TL;DR*

- Kustomize helps customizing config files in a template free way.
- Kustomize provides a number of handy methods like generators to make customization easier.
- Kustomize uses patches to introduce environment specific changes on an already existing standard config file without disturbing it.

## Principles

In some directory containing your YAML resource files (deployments, services, configmaps, etc.), create a `kustomization.yaml` file.
This file should declare those resources, and any customization to apply to them, e.g. add a common label.

Generate customized YAML with: `kustomize build <kustomization_yaml_file_dir>`

Then, you can manage "variants" of a configuration (like development, staging and production) using overlays that modify a common base.

### Base

A base is a kustomization referred to by some other kustomization.
Any kustomization, including an overlay, can be a base to another kustomization.

### Overlays

An overlay is a kustomization that depends on another kustomization.
The kustomizations an overlay refers to (via file path, URI or other method) are called bases.
An overlay is unusable without its bases.
An overlay may act as a base to another overlay.
Overlays make the most sense when there is more than one, because they create different variants of a common base - e.g. development, QA, staging and production environment variants.
These variants use the same overall resources, and vary in relatively simple ways, e.g. the number of replicas in a deployment, the CPU to a particular pod, the data source used in a ConfigMap, etc.

## In practice

_NOTE : you have to be into `delivery/kustomize` folder to run the commands below._

### Display resources from a simple base

Look at the `./base/kustomization.yaml` file : it must have references to the resources to deploy.
These references can be local files or remote URLs.

You can print what resources are resulting from kustomize with :

```
kustomize build base
```
### Deploy variants of the base through overlays

Now let's deploy some variants of the base with different overlays : `dev`, `staging` and `prod`.

#### Dev overlay

Look at `./overlays/dev` to see what are the differences with the base.
Deploy the `dev` variant (you can remove the `| kubectl apply -f -` to see what is going to be deployed):

```
kustomize build ./overlays/dev | kubectl apply -f -
```

Check that resources have been created in `dev` namespace with corresponding labels : `kubectl get all -n dev --show-labels`

Check the app :

```
SVC_IP=$(kubectl -n dev get service helloservice -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SVC_PORT=$(kubectl -n dev get service helloservice -o jsonpath='{.spec.ports[0].port}')
xdg-open http://${SVC_IP}:${SVC_PORT}
```

NOTE : As you can see in the `./overlays/dev/kustomization.yaml` comment, you can also point to a [remote base](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md#url-format). It is very useful to deploy your kustomized version of an open-source tool base without having to maintain it yourself !

#### Staging overlay

Look at the `./overlays/staging` overlay to see what are the differences with the base.
Deploy the `staging` variant (you can remove the `| kubectl apply -f -` to see what is going to be deployed):

```
kustomize build ./overlays/staging | kubectl apply -f -
```

Check that resources have been created in `prod` namespace with corresponding labels : `kubectl get all -n staging --show-labels`

Check the app :

```
SVC_IP=$(kubectl -n staging get service helloservice -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SVC_PORT=$(kubectl -n staging get service helloservice -o jsonpath='{.spec.ports[0].port}')
xdg-open http://${SVC_IP}:${SVC_PORT}
```

#### Prod overlay

Look at the `./overlays/prod` overlay to see what are the differences with the base.
Deploy the `prod` variant (you can remove the `| kubectl apply -f -` to see what is going to be deployed):

```
kustomize build ./overlays/prod | kubectl apply -f -
```

Check that resources have been created in `prod` namespace with corresponding labels : `kubectl get all -n prod --show-labels`

Check the app :

```
SVC_IP=$(kubectl -n prod get service helloservice -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SVC_PORT=$(kubectl -n prod get service helloservice -o jsonpath='{.spec.ports[0].port}')
xdg-open http://${SVC_IP}:${SVC_PORT}
```

### Delete

```
kustomize build ./overlays/dev | kubectl delete -f -
kustomize build ./overlays/staging | kubectl delete -f -
kustomize build ./overlays/prod | kubectl delete -f -
```