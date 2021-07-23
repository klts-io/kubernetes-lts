#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} tag: tag name"
    exit 2
fi

WORKDIR="${WORKDIR:-.}"
cd "${WORKDIR}"

REPO="${REPO:-https://github.com/kubernetes/kubernetes}"
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
git checkout -B "${BRANCH}" "${TAG}"
