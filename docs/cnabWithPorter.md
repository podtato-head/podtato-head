# Delivery the example with CNAB and Porter

## Install porter

Follow the instructions in the [Porter Installation](https://porter.sh/install/)

## Init the project

```porter create```

## Adding manifest files

```COPY ./manifests /cnab/app/manifests```


## Building the project

```porter build```


## Publishing the image

```tag: myregistry/porter-hello:v0.1.0```

```porter publish```


## Installing the bundle

For installing the image locally

```porter install```

Installing the Kubernetes mixin
```porter mixin install Kubernetes```

Installing the helm mixin
```porter mixin install helm```

For installing from the registry

```porter install helloservice-demo --tag aloisreitbauer/helloservice-porter:latest```

## Uninstalling the bundle

Uninstall locally 

```porter uninstall```

Uninstall using installation name

```porter uninstall helloservice-demo```

## References

* 


