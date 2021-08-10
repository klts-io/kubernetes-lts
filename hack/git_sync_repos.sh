#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "$(dirname "${BASH_SOURCE}")/helper.sh"

cd "${REPOSDIR}"

BRANCH="${BRANCH:-$(helper::repos::branch)}"

git add *
git commit -m "Automatic Sync"
git push origin "${BRANCH}"
