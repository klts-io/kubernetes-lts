#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


REGISTRY=${REGISTRY:-}

IMAGES=$(docker images | grep ${REGISTRY} | awk '{print $1":"$2}')
for image in ${IMAGES} ;  do
    docker push "${image}"
done
