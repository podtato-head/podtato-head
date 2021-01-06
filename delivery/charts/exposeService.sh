export POD_NAME=$(kubectl get pods --namespace hello-helm -l "app.kubernetes.io/name=hello-server,app.kubernetes.io/instance=kubecon-release" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace hello-helm $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace hello-helm port-forward $POD_NAME 8080:$CONTAINER_PORT
