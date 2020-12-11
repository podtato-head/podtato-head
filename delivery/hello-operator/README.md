# Delivering the example using a Helm-based operator

## Preparation steps

* [Install the operator sdk](https://docs.openshift.com/container-platform/4.1/applications/operator_sdk/osdk-getting-started.html#osdk-installing-cli_osdk-getting-started)

```
RELEASE_VERSION=v0.8.0
curl -OJL https://github.com/operator-framework/operator-sdk/releases/download/${RELEASE_VERSION}/operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
chmod +x operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
sudo cp operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu /usr/local/bin/operator-sdk
rm operator-sdk-${RELEASE_VERSION}-x86_64-linux-gnu
```

Check operator-sdk is installed :

```
operator-sdk version
```

## What has been done in this project

### Creating the operatior project

Running ```initProject.sh``` will setup the basics for the operator. This script
is just executing the following operator sdk command

```operator-sdk init --plugins=helm --domain=helloservice--group=helloservice-demo --version=v1alpha1 --helm-chart ../charts/```
Which creates a Helm-based operator based on the helm charts example. This will
put everything in values into the CRD. You can find an example in ```./config/samples/```

### Building the operator image

```make docker-build docker-push IMG=aloisreitbauer/helloperator:latest```

### Installing the 'Helloserver' Custom Resource Definition (CRD)

```make install```

### Installing the operator

```make deploy IMG=aloisreitbauer/helloperator:latest```

### Installing the 'Helloserver' Custom Resource (CR)

```kubectl apply -f ./config/samples/helloservice-demo_v1alpha1_helloserver.yaml```

### Seeing things in action

### Cleaning up

```
kubectl delete -f ./config/samples/helloservice-demo_v1alpha1_helloserver.yaml
make undeploy
```

## References

* [https://sdk.operatorframework.io/docs/building-operators/helm/tutorial/]