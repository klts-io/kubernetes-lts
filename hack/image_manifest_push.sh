#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"
cd "${WORKDIR}"

REGISTRY=${REGISTRY:-}
TAG=$(helper::workdir::version)

DOCKER_CLI_EXPERIMENTAL=enabled

docker images

echo "REGISTRY: ${REGISTRY}"
echo "TAG:      ${TAG}"

IMAGES=$(docker images | awk '{print $1":"$2}' | grep -E "^${REGISTRY}/" | grep -E ":${TAG}$" || :)
echo "IMAGES:   ${IMAGES}"

declare -A IMAGE_ARCH=()

for image in ${IMAGES}; do
    name_arch_tag="${image##*/}"
    tag="${name_arch_tag##*:}"
    name_arch="${name_arch_tag%:*}"
    name="${name_arch%-*}"
    arch="${name_arch##*-}"

    if [[ -v "IMAGE_ARCH[${name}]" ]]; then
        IMAGE_ARCH["${name}"]+=" ${arch}"
    else
        IMAGE_ARCH["${name}"]="${arch}"
    fi
done

OS="linux"

for name in ${!IMAGE_ARCH[@]}; do
    echo "+++ Creating manifest image ${REGISTRY}/${name}:${tag}"

    echo "+++ Pushing images"
    manifests=""
    for arch in ${IMAGE_ARCH[${name}]}; do
        docker tag "${REGISTRY}/${name}-${arch}:${TAG}" "${REGISTRY}/${name}:${TAG}__${arch}_${OS}"
        docker push "${REGISTRY}/${name}:${TAG}__${arch}_${OS}"
        manifests+=" ${REGISTRY}/${name}:${TAG}__${arch}_${OS}"
    done

    echo "+++ Creating manifest"
    docker manifest create --amend "${REGISTRY}/${name}:${TAG}" ${manifests}

    echo "+++ Annotating manifest with ARCH and OS"
    for arch in ${IMAGE_ARCH[${name}]}; do
        docker manifest annotate "${REGISTRY}/${name}:${TAG}" "${REGISTRY}/${name}:${TAG}__${arch}_${OS}" --arch "${arch}" --os "${OS}"
    done

    echo "+++ Pushing manifest ${REGISTRY}/${name}:${TAG}"
    docker manifest push "${REGISTRY}/${name}:${TAG}" --purge
done
