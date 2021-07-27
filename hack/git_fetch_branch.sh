#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
    echo "${0} branch: fetch and checkout to the branch"
    exit 2
fi

source "$(dirname "${BASH_SOURCE}")/helper.sh"
cd "${WORKDIR}"

BRANCH="$1"
ORIGIN="origin-pull-branch-${BRANCH}"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi
git remote add "${ORIGIN}" "${REPO}"

git fetch "${ORIGIN}" "${BRANCH}" --depth=1
git checkout -f -B "${BRANCH}" --track "${ORIGIN}/${BRANCH}"
