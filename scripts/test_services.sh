#! /usr/bin/env bash

declare -r this_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
declare -r root_dir=$(cd ${this_dir}/.. && pwd)

target_namespace=${1:-podtato-kubectl}
ADDR=127.0.0.1
PORT=9000

echo "INFO: forwarding port ${ADDR}:${PORT} to service/podtato-head-entry in namespace/${target_namespace}"
kubectl port-forward --namespace ${target_namespace} --address ${ADDR} service/podtato-head-entry ${PORT}:9000 &> /dev/null &
pid=$!
trap "kill ${pid} &> /dev/null" EXIT
sleep 3

set +e
echo "=== Testing API endpoints"
ret=0
curl --fail --silent --output /dev/null http://localhost:${PORT}/
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get home page"
    ret=2 
else
    echo "GOT home page"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/assets/css/styles.css
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get static asset"
    ret=2
else
    echo "GOT static asset"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/hat/hat.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get hat.svg"
    ret=2
else
    echo "GOT hat.svg"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/right-leg/right-leg.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get right-leg.svg"
    ret=2
else
    echo "GOT right-leg.svg"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/right-arm/right-arm.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get right-arm.svg"
    ret=2
else
    echo "GOT right-arm.svg"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/left-leg/left-leg.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get left-leg.svg"
    ret=2
else
    echo "GOT left-leg.svg"
fi

curl --fail --silent --output /dev/null http://localhost:${PORT}/parts/left-arm/left-arm.svg
if [[ $? != 0 ]]; then
    >&2 echo "FAILed to get left-arm.svg"
    ret=2
else
    echo "GOT left-arm.svg"
fi

exit ${ret}
