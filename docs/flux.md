# Delivery using Flux

## Install Flux


## Adjust deployment

Get the current deployment using

kubectl get Deployment flux -n flux -o yaml > deployment.yaml

Make the following changes

```
  ... 
    spec:
      containers:
      - args:
        - --memcached-service=
        - --ssh-keygen-dir=/var/fluxd/keygen
        - --git-url=
        - --git-branch=main
        - --git-path= delivery/manifest
        - --git-label=flux
        - --git-user=
        - --git-email=
        - --listen-metrics=:3031

   ...
```

## Update the deployment


## Set the deployment key for the Github Repo

fluxctl identity --k8s-fwd-ns flux  > mykey.key