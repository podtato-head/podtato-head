# Delivery using Flux

## Install Flux


## Adjust deployment

Get the current deployment using

```
 ./geFluxDeployment
```
This will execute and get the current flux deployment

```
kubectl get Deployment flux -n flux -o yaml > deployment.yaml

```

Next the ```git-branch``` and ```git-path``` need to be chagned as well as the
```git-url```

For the demo to work faster consider also adding   
 ```- --git-poll-interval=1m``` which will reduce the polling interval from 5
 minutes to 1 minute 

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

Simply apply the changed manifest

```
kubectl apply -f ./Deployment.yaml
```


## Set the deployment key for the Github Repo

After updating the deployment we need get the deploy key and configure it in our
repository

```
  fluxctl identity --k8s-fwd-ns flux  > mykey.key
```