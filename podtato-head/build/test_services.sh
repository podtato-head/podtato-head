#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r app_dir=$(cd ${this_dir}/.. && pwd)
declare -r root_dir=$(cd ${this_dir}/../.. && pwd)

github_user=${1:-${GITHUB_USER}}
github_token=${2:-${GITHUB_TOKEN}}

temp_dir=$(mktemp -d)

kind_ver=0.11.1
curl -sSLo ${temp_dir}/kind https://github.com/kubernetes-sigs/kind/releases/download/v${kind_ver}/kind-linux-amd64
chmod +x ${temp_dir}/kind
export PATH=${temp_dir}:${PATH}

export KUBECONFIG=${temp_dir}/kube.config

${temp_dir}/kind version
${temp_dir}/kind create cluster --kubeconfig ${KUBECONFIG} --wait 60s

kubectl cluster-info

echo ""
echo "=== Testing kubectl deployment..."
${root_dir}/delivery/kubectl/test.sh "${github_user}" "${github_token}"

kubectl get pods

ADDR=127.0.0.1
PORT=9000
# will be killed when cluster is deleted
kubectl port-forward --namespace podtato-kubectl --address ${ADDR} svc/podtato-entry ${PORT}:9000 &> /dev/null &
sleep 3

echo ""
echo "=== Testing API endpoints"
ret=0
curl --fail --silent --output /dev/null http://localhost:${PORT}/
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get home page"
    ret=2 
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/assets/css/styles.css
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get static asset"
    ret=2
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/hat/hat.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get hat.svg"
    ret=2
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/right-leg/right-leg.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get right-leg.svg"
    ret=2
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/right-arm/right-arm.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get right-arm.svg"
    ret=2
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/left-leg/left-leg.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get left-leg.svg"
    ret=2
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/left-arm/left-arm.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get left-arm.svg"
    ret=2
fi

echo ""
echo "=== kubectl logs deployment/podtato-entry"
kubectl logs deployment/podtato-entry

echo ""
echo "=== kubectl logs deployment/podtato-hat"
kubectl logs deployment/podtato-hat

echo ""
if [[ -n "${WAIT_FOR_DELETE}" ]]; then
    read -N 1 -s -p "press a key to continue..."
fi

echo ""
echo ""
${temp_dir}/kind delete cluster
exit ${ret}
