# Use KubeVela to deploy the application

## Prerequisite:

* Kubernetes cluster with ingress installed.
* Make sure you have finished and verified the installation following this [guide](https://kubevela.io/#/en/install).

## Steps

* Install KubeVela on your Kubernetes cluster:

`vela install`

* Deploy the application:
Create the namespace:   
`vela env init demo --namespace demospace`   
Deploy the `helloservice`:   
`vela up`   

* Check the status of your application
  
`vela status helloservice`

```bash
About:

  Name:      	helloservice                        
  Namespace: 	demo                                
  Created at:	2020-12-10 13:46:18.266925 -0800 PST
  Updated at:	2020-12-10 13:46:18.266925 -0800 PST

Services:

  - Name: server
    Type: webservice
    HEALTHY Ready:1/1 
    Traits:
      - ✅ route: 	Visiting URL: http://example.com	IP: 47.89.253.147

    Last Deployment:
      Created at: 2020-12-10 13:46:18 -0800 PST
      Updated at: 2020-12-10T13:46:18-08:00
```

* Verify the installation

`curl -H "Host:example.com" http://<ingressIP>`