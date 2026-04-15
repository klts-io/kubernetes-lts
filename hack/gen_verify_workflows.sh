#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source "kit/helper.sh"

RELEASES=$(helper::config::list_releases)
ALL_RELEASES=""
for release in ${RELEASES}; do
  ALL_RELEASES="${ALL_RELEASES},${release}"
done
ALL_RELEASES="${ALL_RELEASES},"

cat <<EOF
name: Verify

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

  workflow_dispatch:

jobs:
  Patch:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Cache
        uses: actions/cache@v4
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Verify patch
        run: |
          make verify-patch
      - name: Verify patch format
        run: |
          make verify-patch-format

  Select-Releases:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    outputs:
      run_all: \${{ steps.select.outputs.run_all }}
      selected_releases: \${{ steps.select.outputs.selected_releases }}
    steps:
      - id: select
        shell: bash
        env:
          EVENT_NAME: \${{ github.event_name }}
          HEAD_REF: \${{ github.head_ref }}
          PR_TITLE: \${{ github.event.pull_request.title }}
          RELEASES: '${ALL_RELEASES}'
        run: |
          set -o errexit
          set -o nounset
          set -o pipefail

          selected_releases=""
          run_all="false"

          if [[ "\${EVENT_NAME}" != "pull_request" ]]; then
            run_all="true"
            selected_releases="\${RELEASES}"
          else
            selector="\$(echo "\${HEAD_REF} \${PR_TITLE}" | tr '[:upper:]' '[:lower:]')"
            IFS=',' read -r -a release_list <<< "\${RELEASES}"
            for release in "\${release_list[@]}"; do
              if [[ -z "\${release}" ]]; then
                continue
              fi
              release_lower="\$(echo "\${release}" | tr '[:upper:]' '[:lower:]')"
              minor_dot="\$(echo "\${release}" | sed -E 's/^v([0-9]+)\.([0-9]+)\..*/\1.\2/')"
              minor_dash="\${minor_dot/./-}"

              if [[ "\${selector}" == *"\${release_lower}"* ]] || [[ "\${selector}" == *"\${minor_dot}"* ]] || [[ "\${selector}" == *"\${minor_dash}"* ]]; then
                if [[ -z "\${selected_releases}" ]]; then
                  selected_releases=",\${release},"
                else
                  selected_releases="\${selected_releases}\${release},"
                fi
              fi
            done

            if [[ -z "\${selected_releases}" ]]; then
              run_all="true"
              selected_releases="\${RELEASES}"
            fi
          fi

          echo "run_all=\${run_all}" >> "\${GITHUB_OUTPUT}"
          echo "selected_releases=\${selected_releases}" >> "\${GITHUB_OUTPUT}"
          echo "Selected releases: \${selected_releases}"

EOF

for release in ${RELEASES}; do
  name=${release//\./\-}
  cat <<EOF
  Test-${name}:
    needs:
      - Patch
      - Select-Releases
    if: \${{ needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},') }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Cache
        uses: actions/cache@v4
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test
        run: |
          make test

  Test-Cmd-${name}:
    needs:
      - Patch
      - Select-Releases
    if: \${{ needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},') }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Cache
        uses: actions/cache@v4
        env:
          cache-name: src
        with:
          path: |
            src
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test cmd
        run: |
          make test-cmd

  Test-Integration-${name}:
    needs:
      - Patch
      - Select-Releases
    if: \${{ needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},') }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Cache
        uses: actions/cache@v4
        env:
          cache-name: src
        with:
          path: |
            src
            /tmp/kubernetes-lts/
          key: \${{ runner.os }}-build-\${{ env.cache-name }}-${name}
          restore-keys: |
            \${{ runner.os }}-build-\${{ env.cache-name }}
      - name: Config Github
        run: |
          git config --global user.email "noreply@github.com"
          git config --global user.name "GitHub"
      - name: Install dependent
        run: |
          make dependent
      - name: Checkout to ${release}
        run: |
          make ${release}
      - name: Install etcd
        run: |
          make install-etcd
      - name: Test integration
        run: |
          make test-integration

EOF

done
