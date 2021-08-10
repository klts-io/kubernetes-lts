#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

BRANCH="master"
ORIGIN="upstream"

if ! [[ -d .git ]]; then
    git init
fi

if [[ "$(git config user.name)" == "" ]]; then
    git config --global user.name "bot"
fi

if [[ "$(git remote | grep ${ORIGIN})" == "${ORIGIN}" ]]; then
    git remote remove "${ORIGIN}"
fi
git remote add "${ORIGIN}" "${REPO}"

git remote update
