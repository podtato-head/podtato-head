# Using Gimlet CLI to deploy *pod tato Head*

Gimlet CLI is a command line tool that packages a set of conventions and matching workflows so you can manage the GitOps repository effectively.

You can learn more about Gimlet CLI on https://gimlet.io

## Install Gimlet CLI

```
curl -L https://github.com/gimlet-io/gimlet-cli/releases/download/v0.3.0/gimlet-$(uname)-$(uname -m) -o gimlet
chmod +x gimlet
sudo mv ./gimlet /usr/local/bin/gimlet
gimlet --version
```

## Defining environments

Gimlet promotes a declarative environment configuration file that lives in the application source code repository.

Gimlet then offers a CLI command, `gimlet manifest template` to deliver Kubernetes yamls to the GitOps repository.

```
# staging.yaml
app: podtato-head
env: staging
namespace: staging
chart:
  name: ../charts/podtatoserver
  version: 0.1.0
values:
  replicaCount: 1
```

## Templating environments

```
cd delivery/gimlet/
gimlet manifest template \
  -f staging.yaml \ 
  -o manifests.yaml
```

## Writing to GitOps

Gimlet provides helpers to write Kubernetes yamls to the GitOps repository along a set of conventions that unlock advanced features.

```
cd delivery/gimlet/
gimlet manifest template -f staging.yaml | \
  gimlet gitops write -f - \
    --env staging \
    --app podtato-head \
    --gitops-repo-path <<path-to-a-working-copy-of-the-gitops-repo>> \
    -m "Releasing Bugfix 345"
```
