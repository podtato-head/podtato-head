#! /usr/bin/env bash

echo "run v0.1.0 image"
cid=$(docker run -p 9000:9000 -d ghcr.io/podtato-head/podtatoserver:v0.1.0)
trap "docker container rm --force ${cid}" EXIT

echo "get home page"
curl -fs http://localhost:9000/ > /dev/null
if [[ $? != 0 ]]; then
    >&2 echo "ERROR: failed to get home page"
else
    echo "SUCCESS"
fi

echo "get static asset"
curl -fs http://localhost:9000/static/images/left-arm/left-arm-01.svg > /dev/null
if [[ $? != 0 ]]; then
    >&2 echo "ERROR: failed to get static asset"
else
    echo "SUCCESS"
fi

echo "don't get non-existent static asset"
curl -fs http://localhost:9000/static/images/left-arm/left-arm-07.svg > /dev/null
if [[ $? != 22 ]]; then
    >&2 echo "ERROR: got static asset unexpectedly"
else
    echo "SUCCESS"
fi
