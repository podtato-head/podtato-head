#!/bin/sh

kubectl port-forward service/podtatohead-hello-server -n podtatoargocd 9090:9000