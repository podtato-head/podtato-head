# Delivering the example using Keptn

## Installing prerequisites

* Install Prerequisites (Kubernetes, Istio)
  * [Tutorial](https://tutorials.keptn.sh/tutorials/keptn-full-tour-prometheus-07/index.html?index=..%2F..index#6) Step 1-7

For your convenience, commands are listed below :

Install Istio :

```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.6.5 sh -
./istio-1.6.5/bin/istioctl install
```

Install Keptn CLI :

```
curl -sL https://get.keptn.sh | sudo -E bash
keptn version
```

Install Keptn in your cluster :

```
keptn install --endpoint-service-type=ClusterIP --use-case=continuous-delivery
```

Access Keptn UI :

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
````

### Onboard Service
```
./initProject.sh onboard-service
````

### Deploy Service (new-artifact)
```
./initProject.sh first-deploy-service
````

### Upgrade Service (new-artifact)

```
./initProject.sh upgrade-service
````
