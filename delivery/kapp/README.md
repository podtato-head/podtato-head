# Kapp

https://get-kapp.io/

Kapp is a simple deployment tool focused on the concept of "K8S application" = a set of resources with the same label.
Deploy and view groups of Kubernetes resources as "applications".
Apply changes safely and predictably, watching resources as they converge.

_NOTE : you have to be into `delivery/kapp` folder to run the commands below._

## Install

You can install `kapp` CLI with :

```
./setup/install.sh
```

## Basic usages

### Deploy from a directory

- Deploy an application :

```
kapp deploy -a podtatoserver-app -f ../kubectl/manifest.yaml
```

_Note: No need to write a script to wait until all your resources are _really_ created : kapp is waiting for all dependencies of your resources to be ready._

If you try to run the above command a second time, nothing happens : kapp only changes what is necessary.

- Inspect an app : `kapp inspect -a podtatoserver-app --tree`
- Display apps : `kapp ls`
- Update an app :
  - change image tag in `../kubectl/manifest.yaml`
  - display diff before deploying : `kapp deploy -a podtatoserver-app -f ../kubectl/manifest.yaml --diff-changes`
- Delete app : `kapp delete -a podtatoserver-app`

_Note: Those who know Terraform should see similarities regarding resources management._

### Deploy with Helm charts

```
kapp -y deploy -a podtatoserver-chart -f <(helm template ph ../chart/)
```

and simply delete with `kapp delete -a podtatoserver-chart`

### Deploy with Kustomize

```
kapp -y deploy -a podtatoserver-kusto-app -f <(kustomize build ../kustomize/overlay)
```

and simply delete with `kapp delete -a podtatoserver-kusto-app`

## Useful usages

- See what would be deployed

Example : If you want to check what resources Istio is going to deploy in your cluster :

```
kapp deploy -a istio -f <(istioctl manifest generate --set profile=default)
# To abort deployment, enter 'N' or 'Ctrl+C'
```

## TODO

- [ ] Add kapp controller : https://github.com/vmware-tanzu/carvel-kapp-controller/blob/develop/docs/README.md
