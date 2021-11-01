#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

kit/format_patch.sh $@
