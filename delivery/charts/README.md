# Hello Server Helm Chart

## Pre Requisites

* Kubernetes 1.9+
* Requires at least Helm v3.0.0

## Installing the Chart

The chart is currently available via Git in a local directory. To install the
chart first checkout the source code, open a terminal, and move to the delivery
sub-directory. Then run

```
helm install hs podtatoserver
```

This will install the _podtatoserver_ chart under the name `hs`.

The installation can be customized by changing the following paramaters:

| Parameter                       | Description                                                     | Default                      |
| ------------------------------- | ----------------------------------------------------------------| -----------------------------|
| `replicaCount`                  | Number of replicas of the container                             | `1`                          |
| `image.repository`              | Podtato Head Container image name                               | `ghcr.io/podtato-head/podtatoserver`|
| `image.tag`                     | Podtato Head image tag                                          | `v0.1.2`                     |
| `image.pullPolicy`              | Podtato Head Container pull policy                              | `IfNotPresent`               |
| `imagePullSecrets`              | Podtato Head Pod pull secret                                    | ``                           |
| `serviceAccount.create`         | Whether or not to create dedicated service account              | `true`                       |
| `serviceAccount.name`           | Name of the service account to use                              | `default`                    |
| `serviceAccount.annotations`    | Annotations to add to a created service account                 | `{}`                         |
| `podAnnotations`                | Map of annotations to add to the pods                           | `{}`                         |
| `ingress.enabled`               | Enables Ingress                                                 | `false`                      |
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
| `service.type`                  | Kubernetes Service type                                         | `ClusterIP`                  |
| `service.port`                  | The port the service will use                                   | `9000`                       |

## Updating the version

To update the application version, you can choose one of the following methods :

- update the `image.tag` value in `values.yaml` (set the value to `v0.1.1`) and run `helm upgrade hs podtatoserver`
- run `helm upgrade hs podtatoserver --set image.tag=v0.1.1`

A new revision is then installed.

## Rollback to a previous version

To rollback to a previous revision, run :

```
# Check revision history
helm history hs

# Rollback to the revision 1
helm rollback hs 1

# Check the revision
helm status hs
```

## Uninstall the chart

```
helm uninstall hs
```

## Notes

1. The chart was started by using the command `helm create` and then modified from there
2. The JSON Schema was generated using [this](https://github.com/karuppiah7890/helm-schema-gen) Helm plugin.