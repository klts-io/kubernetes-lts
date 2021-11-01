#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kit/git_sync_repos.sh
