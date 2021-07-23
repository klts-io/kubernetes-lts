#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


OLD_REGISTRY=${OLD_REGISTRY:-}
REGISTRY=${REGISTRY:-}
OLD_IMAGES=$(docker images | grep ${OLD_REGISTRY} | grep kube- | grep -v cross | awk '{print $1":"$2}')
for old_image in ${OLD_IMAGES} ;  do
    new_image=$(echo ${old_image} | sed "s#${OLD_REGISTRY}#${REGISTRY}#g")
    docker tag "${old_image}" "${new_image}"
    docker rmi "${old_image}"
done
