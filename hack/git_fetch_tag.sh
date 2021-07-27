#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} tag: fetch and checkout to the tag"
    exit 2
fi

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

TAG="$1"
BRANCH="tag-${TAG}"
ORIGIN="origin-pull-${BRANCH}"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi
git remote add "${ORIGIN}" "${REPO}"

git fetch "${ORIGIN}" tag "${TAG}" --depth=1
git checkout -f -B "${BRANCH}" "${TAG}"
