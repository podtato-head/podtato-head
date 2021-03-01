# CNAB over an airgap

1. Make any changes necessary to your bundle's source files and build it.

    ```
    porter build
    ```

1. Publish the bundle to a registry. You can change where the bundle is published with the `--tag` flag.

    ```
    porter publish --tag mydockeruser/helloservice-porter:v0.1.0
    ```

1. Archive the bundle to create a tgz file containing the bundle _and_ any images referenced by
    the bundle from the `images` section of the porter.yaml.

    ```
    porter archive helloservice.tgz --tag mydockeruser/helloservice-porter:v0.1.0
    ```

1. Move the tgz file across the airgap, using removable media such as a USB stick or CD.

1. Publish the bundle to a registry on the other side of the airgap.

    ```
    porter publish --archive helloservice.tgz --tag theotherside/helloservice-porter:v0.1.0
    ```

    Porter will publish the bundle, and any referenced images contained in the
    archive, to the destination registry. The installer image and referenced
    images are pushed to a single repository and do not preserve their tags.
    This ensures that when someone installs a bundle, if they have access to the
    bundle repository, they are guaranteed to have access to the installer image
    and the referenced images.
    
    Learn more about what to [expect the images to look like in the destination
    repository](https://porter.sh/distribute-bundles/#image-references-after-publishing).
    There is an [open issue](https://github.com/cnabio/cnab-to-oci/issues/104)
    to preserve the tags.

1. Generate a credential set that says where to find the any credentials
    required by the bundle. In this case, the bundle requires a kubeconfig for a
    cluster on the other side of the airgap. This cluster should have access to
    the airgapped registry where the bundle was published.

    ```console
    $ porter credentials generate kube --tag theotherside/helloservice-porter:v0.1.0
    Generating new credential kube from bundle podtatoserver
    ==> 1 credentials required for bundle podtatoserver
    ? How would you like to set credential "kubeconfig"
    file path
    ? Enter the path that will be used to set credential "kubeconfig"
    $HOME/.kube/config

    $ porter credentials list
    NAME           MODIFIED
    kube           3 hours ago
    ```

1. Install the bundle using the new reference that is accessible on this side of the airgap.

    ```
    porter install helloservice-demo --tag theotherside/helloservice-porter:v0.1.0 -c kube
    ```

You  can inspect the deployment to see that the image used by the deployment is
the one published to the airgapped registry. In the example below the archived
bundle was published to a local docker registry, localhost:5000, to simulate
moving it across an airgap.

```console
$ kubectl describe deployment -n demospace helloservice
Name:                   helloservice
Namespace:              demospace
CreationTimestamp:      Fri, 23 Oct 2020 14:00:27 -0500
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=helloservice
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=helloservice
  Containers:
   server:
    Image:      localhost:5000/helloservice-porter@sha256:3fe55b2bc6c9a31a2acdd7ee5c64cb076a267c11443d9bb12c1467272bf9af07
    Port:       9000/TCP
    Host Port:  0/TCP
    Environment:
      PORT:  9000
    Mounts:  <none>
  Volumes:   <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  <none>
NewReplicaSet:   helloservice-76c9c95775 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  34s   deployment-controller  Scaled up replica set helloservice-76c9c95775 to 1
```

## Managing the bundle

If you are testing this locally on the same machine, without a real airgap, make
sure to change directories so that you are not in the bundle's source directory
(where the porter.yaml is located). This ensures that the following commands are
executing against the published bundle and are not using the local bundle
source. When the `--tag` flag isn't specified, porter defaults to using the bundle
definition from the porter.yaml in the same directory.

### View installed bundles

```console
$ porter list
NAME                CREATED         MODIFIED        LAST ACTION   LAST STATUS
helloservice-demo   4 minutes ago   4 minutes ago   install       succeeded
```

### Show installation details

```console
porter show helloservice-demo
Name: helloservice-demo
Created: 33 minutes ago
Modified: 2 minutes ago

History:
--------------------------------------
  Action   Timestamp       Status
--------------------------------------
  install  33 minutes ago  succeeded
  upgrade  2 minutes ago   succeeded
```

### Uninstall the bundle

```console
$ porter uninstall helloservice-demo -c kube
```

**NOTE**: We are in the middle of improving publish flags so that it's easier to
work with in parts, such as just changing the destination repo and not having to
specify the bundle version again. Expect the --tag flag to be marked for
deprecation next month (Nov 2020).
