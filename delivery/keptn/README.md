# Delivering the example using Keptn


## Installing prerequisites

* Install Prerequisites (Kubernetes, Istio)
  * [Tutorial](https://tutorials.keptn.sh/tutorials/keptn-full-tour-prometheus-07/index.html?index=..%2F..index#6) Step 1-7
  
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
