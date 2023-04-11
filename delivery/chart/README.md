# Deliver with Helm

Here's how to deliver podtato-head using [Helm](https://helm.sh).

## Prerequisites

- Install Helm ([official instructions](https://helm.sh/docs/intro/install/))

## Deliver

You must clone this repo and install from a local copy of the chart:

```
git clone https://github.com/podtato-head/podtato-head.git && cd podtato-head
helm install podtato-head ./delivery/chart
```

This will install the chart in this directory with release name `podtato-head`.

> NOTE: You can instruct helm to wait for the resources to be ready before
marking the release as successful by adding the `--wait` option to the previous
command.

The installation can be customized by changing the following parameters via
`--set` or a custom `values.yaml` file specified with `--values`:

| Parameter                       | Description                                                     | Default                      |
| ------------------------------- | ----------------------------------------------------------------| -----------------------------|
| `replicaCount`                  | Number of replicas of the container                             | `1`                          |
| `images.repositoryDirname`      | Prefix for image repos                                          | `ghcr.io/podtato-head`       |
| `images.pullPolicy`             | Podtato Head Container pull policy                              | `IfNotPresent`               |
| `images.pullSecrets`            | Podtato Head Pod pull secret                                    | `[]`                         |
| `<service>.repositoryBasename`  | Leaf part of name of image repo for <service>                   | `entry`, `hat`, etc.         |
| `<service>.tag`                 | Tag of image repo for <service>                                 | `0.1.0`                      |
| `<service>.serviceType`         | Service type for <service>                                      | `LoadBalancer` for main      |
| `<service>.servicePort`         | Service port for <service>                                      | `9000`-`9005`                |
| `<service>.env`                 | Add "env:" entries on Deployments (ex: PODTATO_PART_NUMBER)     | `[]`                         |
| `serviceAccount.create`         | Whether or not to create dedicated service account              | `true`                       |
| `serviceAccount.name`           | Name of the service account to use                              | `default`                    |
| `serviceAccount.annotations`    | Annotations to add to a created service account                 | `{}`                         |
| `podAnnotations`                | Map of annotations to add to the pods                           | `{}`                         |
| `ingress.enabled`               | Enables Ingress                                                 | `false`                      |
| `ingress.className`             | IngressClass that will be be used (Kubernetes 1.18+)            | `""`                         |
| `ingress.annotations`           | Ingress annotations                                             | `{}`                         |
| `ingress.hosts`                 | Ingress accepted hostnames                                      | `[]`                         |
| `ingress.tls`                   | Ingress TLS configuration                                       | `[]`                         |
| `autoscaling.enabled`           | Enable horizontal pod autoscaler                                | `false`                      |
| `autoscaling.targetCPUUtilizationPercentage`  | Target CPU utilization                            | `80`                         |
| `autoscaling.targetMemoryUtilizationPercentage`  | Target Memory utilization                      | `80`                         |
| `autoscaling.minReplicas`       | Min replicas for autoscaling                                    | `1`                          |
| `autoscaling.maxReplicas`       | Max replicas for autoscaling                                    | `100`                        |
| `tolerations`                   | List of node taints to tolerate                                 | `[]`                         |
| `resources`                     | Resource requests and limits                                    | `{}`                         |
| `nodeSelector`                  | Labels for pod assignment                                       | `{}`                         |

## Test

Verify the release succeeded:

```
helm list
kubectl get pods
kubectl get services
```

### Test the API endpoint

To connect to the API you'll first need to determine the correct address and
port.

If using a LoadBalancer-type service for `entry`, get the IP address of the load balancer
and use port 9000:

```
ADDR=$(kubectl get service podtato-head-entry -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=9000
```

If using a NodePort-type service, get the address of a node and the service's
NodePort as follows:

```
NODE_NAME=$(kubectl get nodes --output json | jq -r '.items[].metadata.name' | head -n 1)
ADDR=$(kubectl get nodes ${NODE_NAME} -o jsonpath={.status.addresses[0].address})
PORT=$(kubectl get services podtato-head-entry -ojsonpath='{.spec.ports[0].nodePort}')
```

If using a ClusterIP-type service, run `kubectl port-forward` in the background
and connect through that:

> NOTE: Find and kill the port-forward process afterwards using `ps` and `kill`.

```
# Choose below the IP address of your machine you want to use to access application 
ADDR=127.0.0.1
# Choose below the port of your machine you want to use to access application 
PORT=9000
kubectl port-forward --address ${ADDR} svc/podtato-head-entry ${PORT}:9000 &
```

Now test the API itself with curl and/or a browser:

```
curl http://${ADDR}:${PORT}/
xdg-open http://${ADDR}:${PORT}/
```

## Update

To update the application version, you can choose one of the following methods :

- update `<service>.tag` in `values.yaml` for each service and run `helm upgrade podtato-head ./delivery/chart`
- run `helm upgrade podtato-head ./delivery/chart --set entry.tag=0.1.1 --set leftLeg.tag=0.1.1 ...`

A new revision is then installed.

> NOTE : to ensure idempotency between the first installation and the following updates, you should use the following command :

```
helm upgrade --install podtato-head ./delivery/chart
```

## Rollback

To rollback to a previous revision, run :

```
# Check revision history
helm history podtato-head

# Rollback to the revision 1
helm rollback podtato-head 1

# Check the revision
helm status podtato-head
```

## Uninstall

```
helm uninstall podtato-head
```
