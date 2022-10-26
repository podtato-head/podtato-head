# Deliver with Kluctl

Here's how to deliver podtato-head using [kluctl](https://kluctl.io).

See [this](https://www.youtube.com/watch?v=9LoYLjDjOdg) video for an introduction to Kluctl.

Kluctl allows you to deploy [targets](https://kluctl.io/docs/reference/kluctl-project/targets/) instead
of just a set of manifests. In it's simplest form, a target simply defines a name and a set of arguments.
The arguments are meant as entry points into templating with Kluctl and allow you to perform advanced
configuration management.

## Prerequisites

- Install Kluctl ([official docs](https://kluctl.io/docs/installation/))
- Setup a cluster for testing purposes (e.g. with [kind](https://kind.sigs.k8s.io/))

For the `test` target, it doesn't really matter how the kubeconfig context is called as Kluctl will always
deploy to the current cluster. For the `prod` cluster, you must create a context named `podtato-prod-cluster`
due to the target being bound to that context. See `delivery/kluctl/.kluctl.yaml` for the target definitions.

## Deploy

To deploy the `test` target, run `kluctl deploy -t test`. Before doing so, ensure that the correct kubeconfig
context is active. When running the deploy command, Kluctl will first perform a dry-run and ask for confirmation.
If you select `y`, Kluctl will perform the actual deployment and then print the resulting diff of the deployment:

```shell
$ kluctl deploy -t test
...
New objects:
  Namespace/test-podtato-microservices
  test-podtato-microservices/ConfigMap/podtato-head-service-discovery
  test-podtato-microservices/Deployment/podtato-head-cap
  test-podtato-microservices/Deployment/podtato-head-entry
...
```

To deploy the `prod` target, run `kluctl deploy -t prod`. It doesn't matter which kubeconfig context is active at
that point as it will enforce the use of the `podtato-prod-cluster` context.

## Test

Check for resources in the current context: `kubectl get all -n test-podtato-microservices`.

To access the podtato service, follow the instructions in the
[kustomize delivery](../kustomize/README.md#test-the-api-endpoint) but for the `test-podtato-microservices`
namespace.

## Modifying and re-deploying

After the initial deployment, find something that is worth being modified and then re-run the deploy command from
above. Kluctl will then show what would be changed and ask for confirmation. If you select `y`, it will apply the
changes and again print the diff afterwards.

## Configuration

You should also look into `delivery/kluctl/config` and the .yaml files in that directory. These are used to configure
the deployment. These are loaded from the root `deployment.yaml` via the `vars` field. Each loaded
[variable source](https://kluctl.io/docs/reference/templating/variable-sources/) (in this case it's the `file` source)
is merged into the templating context and then available by all deployment items referenced from that `deployment.yaml`.

## Housekeeping (e.g. after a refactoring)

Try to rename a deployment, e.g. `podtato-head-hat` to `podtato-head-hut` via:

```shell
$ cd delivery/kluctl/podtato-services
$ find . -name '*.yaml' | xargs sed -i.kluctl-bak 's/podtato-head-hat/podtato-head-hut/g'
$ find . -name '*.kluctl-bak' | xargs rm
```

Then try to re-deploy the `test` target:

```shell
$ kluctl deploy -t test
...
New objects:
  test-podtato-microservices/Deployment/podtato-head-hut
  test-podtato-microservices/Service/podtato-head-hut

Changed objects:
  test-podtato-microservices/ConfigMap/podtato-head-service-discovery

Diff for object test-podtato-microservices/ConfigMap/podtato-head-service-discovery
+-----------------------------+--------------------------------------------------------------------+
| Path                        | Diff                                                               |
+-----------------------------+--------------------------------------------------------------------+
| data["servicesConfig.yaml"] | @@ -1,4 +1,4 @@                                                    |
|                             | -hat:       "http://podtato-head-hat:9001"                         |
|                             | +hat:       "http://podtato-head-hut:9001"                         |
|                             |  left-leg:  "http://podtato-head-left-leg:9002"                    |
|                             |  left-arm:  "http://podtato-head-left-arm:9003"                    |
|                             |  right-leg: "http://podtato-head-right-leg:9004"                   |
+-----------------------------+--------------------------------------------------------------------+

Orphan objects:
  test-podtato-microservices/Deployment/podtato-head-hat
  test-podtato-microservices/Service/podtato-head-hat
? The diff succeeded, do you want to proceed? (y/N) y
...
New objects:
  test-podtato-microservices/Deployment/podtato-head-hut
  test-podtato-microservices/Service/podtato-head-hut

Changed objects:
  test-podtato-microservices/ConfigMap/podtato-head-service-discovery

Diff for object test-podtato-microservices/ConfigMap/podtato-head-service-discovery
+-----------------------------+--------------------------------------------------------------------+
| Path                        | Diff                                                               |
+-----------------------------+--------------------------------------------------------------------+
| data["servicesConfig.yaml"] | @@ -1,4 +1,4 @@                                                    |
|                             | -hat:       "http://podtato-head-hat:9001"                         |
|                             | +hat:       "http://podtato-head-hut:9001"                         |
|                             |  left-leg:  "http://podtato-head-left-leg:9002"                    |
|                             |  left-arm:  "http://podtato-head-left-arm:9003"                    |
|                             |  right-leg: "http://podtato-head-right-leg:9004"                   |
+-----------------------------+--------------------------------------------------------------------+

Orphan objects:
  test-podtato-microservices/Deployment/podtato-head-hat
  test-podtato-microservices/Service/podtato-head-hat
```

You might realize that renaming objects in Kubernetes is something that is actually not possible, meaning that
the above renaming operation will actually cause the creation of completely new objects. This will leave the cluster
with two versions of the same objects, with the old ones being "garbage" or "orphan". Kluctl will notify you about these
orphan objects and allow you to clean these up with the [prune](https://kluctl.io/docs/reference/commands/prune/) call:

```shell
$ kluctl prune -t test
...
ⓘ The following objects will be deleted:
ⓘ   test-podtato-microservices/Deployment/podtato-head-hat
ⓘ   test-podtato-microservices/Service/podtato-head-hat
? Do you really want to delete 2 objects? (y/N) y

Deleted objects:
  test-podtato-microservices/Deployment/podtato-head-hat
  test-podtato-microservices/Service/podtato-head-hat
```

## Purge

To delete the `test` and `prod` targets, run:

```shell
$ kluctl delete -t test
$ kluctl delete -t prod
```

Select `y` when Kluctl asks for confirmation.
