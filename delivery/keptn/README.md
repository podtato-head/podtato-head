# Delivering the example using Keptn

## Installing prerequisites

* Install Prerequisites (Kubernetes, Istio)
  * [Tutorial](https://tutorials.keptn.sh/tutorials/keptn-full-tour-prometheus-08/index.html?index=..%2F..index#3) Step 1-7

For your convenience, commands are listed below :

Install Istio:

```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.8.2 sh -
./istio-1.8.2/bin/istioctl install
```

Install Keptn CLI:

```
curl -sL https://get.keptn.sh | sudo -E bash
keptn version
```

Install Keptn in your cluster:

```
keptn install --endpoint-service-type=ClusterIP --use-case=continuous-delivery
```

Access Keptn UI:

```
# Port-forward keptn service
kubectl -n keptn port-forward service/api-gateway-nginx 8080:80 &

# Set Keptn authentication
KEPTN_ENDPOINT=http://localhost:8080/api
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN

# Display Keptn credentials
keptn configure bridge --output
```

You can now login into Keptn portal.

## Deployment

### Create Project

```
./initProject.sh create-project
```

### Onboard Service
```
./initProject.sh onboard-service
```

### Deploy Service
```
./initProject.sh first-deploy-service
```

### Upgrade Service

```
./initProject.sh upgrade-service
```

### Install Prometheus service

Download the Keptn's Prometheus service manifest

```bash
kubectl apply -f  https://raw.githubusercontent.com/keptn-contrib/prometheus-service/release-0.6.1/deploy/service.yaml
```

Install Role and Rolebinding to permit Keptn's prometheus-service for performing operations in the Prometheus installed namespace.

```bash
kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/release-0.6.1/deploy/role.yaml -n monitoring
```

Set up the Prometheus Alerting Manager rules:

```bash
keptn configure monitoring prometheus --project=pod-tato-head --service=helloservice
```

### Adding quality gates

Adding SLIs and SLOs:

```bash
./initProject.sh add-quality-gates
```

Adding JMeter load tests:

```bash
./initProject.sh add-jmeter-tests
```

Deploy service to check quality-gates:

```bash
./initProject.sh deploy-service
```

Deploy a slow-build that should fail the quality-gates test:

```bash
./initProject.sh slow-build
```
