# Delivery the example with CNAB and Porter

See the [airgap example](/delivery/CNABwithPorter/README.md) for an end-to-end
walkthrough of Porter to publish a bundle across an airgap.

## Install porter

Follow the instructions in the [Porter Installation](https://porter.sh/install/)

## Init the bundle

```
porter create
```

## Adding files

By default files in the same directory as porter.yaml are copied into the bundle
for you. If you want to customize the bundle's installer image, you can use a
[Dockerfile Template](https://porter.sh/custom-dockerfile/) and a .dockerignore
file.

## Building the bundle

```
porter build
```

If you are using any mixins that aren't installed by default by Porter, or you want to update the mixin to the latest version, do so before running the build command.

Installing the [kubernetes mixin](https://porter.sh/mixins/kubernetes) (installed by default)

```
porter mixin install Kubernetes
```

Installing the [helm mixin](https://porter.sh/mixins/helm) (installed by default)

```
porter mixin install helm
```

Installing the [kustomize mixin](https://github.com/donmstewart/porter-kustomize)
```
porter mixin install kustomize --version 0.2-beta-4 --url https://github.com/donmstewart/porter-kustomize/releases/download
```


## Publishing the bundle

By default the bundle is published to the tag defined in porter.yaml.

```
porter publish
```

You can specify an alternate destination with the `--tag` flag:

```
porter publish --tag yourname/thebundle:v0.1.0
```

## Installing the bundle

When you are testing out the bundle, you can install it directly from source by 
running install command in the same directory as the porter.yaml file.

```
porter install
```

Use the `--tag` to install a published bundle:

```
porter install helloservice-demo --tag ghcr.io/podtato-head/helloservice-porter:v0.1.0
```

## Uninstalling the bundle

Uninstall the bundle from source:

```
porter uninstall
```

Uninstall using installation name:

```
porter uninstall helloservice-demo
```

\* When working with an installation from a published bundle, don't run porter commands
from the same directory as the bundle source. Otherwise the operations will use the latest
source instead of the published bundle.

## References

* [Distribute Bundles with Porter](https://porter.sh/distribute-bundles/) -
  Details on what porter is doing during a publish
* [Referencing images in a bundle](https://porter.sh/author-bundles/#images) -
  Define images to include in a bundle for airgap scenarios.
