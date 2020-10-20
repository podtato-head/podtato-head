# Delivering the example with a canary release using ArgoCD




## Create a project



## Find our current rollout with the command lin

```
argo rollouts list rollouts -n demospace-argo
```

## Watch the current rollout on the command line

```
kubectl argo rollouts get rollout helloserver-demo  -w -n demospace-argo
```
## Update the release in the values file


## Manually promote the rollout after the first canary steps

```
kubectl argo rollouts promote helloserver-demo -n demospace-argo
```

