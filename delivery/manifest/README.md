# Delivering the example using a plain manifest

## Installing the Manifest

The manifest is currently available via Git in a local directory. To install the
manifest first checkout the source code, open a terminal, and move to the delivery/manifest
sub-directory. Then run:

```
kubectl apply -f ./manifest.yaml
```

This will install a service and a deployment in the ```demospace ``` namespace.
