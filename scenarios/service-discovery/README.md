# Dynamic service discovery

Use this scenario with the base chart for podtato-head to demonstrate dynamic
service discovery. In this example we will change podtato-head man's hat by
returning a different URL for the hat service.

## Steps

First deploy the base podtato-head services:

1. Deploy podtato-head using [the Helm chart](../../delivery/chart):
   `helm install podtato-head ./delivery/chart`. Find its resources in namespace
   `podtato-helm`.
1. Open a web page to the entry service. Use the NodePort or LoadBalancer
   addresses as discussed in the [Helm chart README](../../delivery/chart/README.md#test).
   Note the hat on podtato-head man.

Now deploy an extra "hat" service and redirect "hat" requests there. This "hat"
service will return a different hat.

1. Deploy an additional "hat" service described in this directory by running
   `helm install podtato-head-ext ./scenarios/service-discovery`
1. Edit the configmap used for service discovery: `kubectl edit configmap -n podtato-helm
   podtato-head-service-discovery`
1. Edit the "hat" entry in the configmap to point to the newly-deployed service
   at "http://podtato-head-ext-hat-beta:9001".
1. Delete the existing pod for the entry deployment:
   `kubectl delete pod -n podtato-helm -l "app.kubernetes.io/component=podtato-head-entry"`.
   A new pod will be created which will reference the updated service discovery config.
1. Finally, open the web page to the entry services to view the _new_ hat on
   podtato-head man.
