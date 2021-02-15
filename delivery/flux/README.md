# Delivery using Flux

## Resources

For more detailed information about Flux installation see the flux documentation [here][1]

## Guide

This guide is adapted from the [Getting Started][6] guide in the Flux documentation.

By the end of this guide you will have
- Deployed Flux in Cluster
- Configured Flux to deploy manifests from a Git Repository

### Prerequisites

You will need
- A Kubernetes Cluster
- Flux CLI tool. [Installation Instructions][2]
- A GitHub Personal access token that can create new repositories (Check all permissions under repo). [Instructions][3]

### Bootstrapping flux

Export your GitHub personal access token and username:

```
$ export GITHUB_TOKEN=<your-token>
$ export GITHUB_USER=<your-username>
```

Run the bootstrap command:

```
$ flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=podtato-test \
  --personal \
  --private=false
```

The bootstrap command creates a repository if one doesn't exist, commits manifests for Flux Components to the default branch, and installs the flux components. Then it configures the target cluster to synchronize with the repository.

### Clone the git repository

We are going to drive app deployments in a GitOps manner, using the Git repository as the desired state for our cluster. Instead of applying the manifests directly to the cluster, Flux will apply it for us instead.

Therefore, we need to clone the repository to our local machine:

```
$ git clone https://github.com/$GITHUB_USER/podtato-test
$ cd podtato-test
```

### Adding Podtato repository to Flux

Create a GitRepository manifest `helloservice` pointing to [podtato-head][4] repository's main branch:

```
 flux create source git helloservice \
--url=https://github.com/cncf/podtato-head \
--branch=main \
--interval=30s \
--export > ./helloservice-source.yaml
```

Commit and push the manifest to the `podtato-test` repository:

```
$ git add helloservice-source.yaml 
$ git commit -m "Add GitRepository Source for helloservice"
$ git push
```

### Deploying helloservice

We will create a Flux Kustomization manifest for helloservice. This configures Flux to build and apply the [manifest][5] directory located in the podtato-head repository.
```
$ flux create kustomization helloservice \
--source=helloservice \
--path="./delivery/manifest" \
--prune-true \
--validation=client \
--interval=5m \
--export > ./helloservice-kustomization.yaml
```

Commit and push the Kustomization manifest to the repository:

```
$ git add helloservice-kustomization.yaml 
$ git commit -m "Add helloservice Kustomization"
$ git push
```

The structure of your repository should look like this

```
├── README.md
├── flux-system
│   ├── gotk-components.yaml
│   ├── gotk-sync.yaml
│   └── kustomization.yaml
├── helloservice-kustomization.yaml
└── helloservice-source.yaml
```

### Watch Flux sync the application

In about 30s the synchronization should start:

```
$ watch flux get kustomizations
NAME            READY   MESSAGE                                                         REVISION                                        SUSPENDED 
flux-system     True    Applied revision: main/4c2a9d272176a36fec9acf9eab75447410fe5573 main/4c2a9d272176a36fec9acf9eab75447410fe5573   False    
helloservice    True    Applied revision: main/0e3e9cffa177185c57d01d9bc067950dce221c7c main/0e3e9cffa177185c57d01d9bc067950dce221c7c   False    
```

When the synchronization finishes you can check that helloservice has been deployed on your cluster:

```
$ kubectl -n demospace get deployments,services 
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloservice   1/1     1            1           40m

NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/helloservice   LoadBalancer   10.96.124.100   <pending>     9000:30579/TCP   40m
```

[1]: https://toolkit.fluxcd.io/guides/installation/
[2]: https://toolkit.fluxcd.io/guides/installation/#install-the-flux-cli
[3]: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
[4]: https://github.com/cncf/podtato-head
[5]: https://github.com/cncf/podtato-head/tree/main/delivery/manifest
[6]: https://toolkit.fluxcd.io/get-started/