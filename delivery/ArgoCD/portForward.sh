#!/bin/sh

kubectl port-forward service/podtatohead-podtatoserver -n podtatoargocd 9090:9000