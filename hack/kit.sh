#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

git clone --single-branch --depth 1 https://github.com/klts-io/kit
