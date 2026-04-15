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
  issue_comment:
    types: [created]

  workflow_dispatch:

jobs:
  Select-Releases:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: read
    outputs:
      run_requested: \${{ steps.select.outputs.run_requested }}
      run_all: \${{ steps.select.outputs.run_all }}
      selected_releases: \${{ steps.select.outputs.selected_releases }}
      checkout_ref: \${{ steps.select.outputs.checkout_ref }}
    steps:
      - id: select
        uses: actions/github-script@v7
        env:
          RELEASES: '${ALL_RELEASES}'
        with:
          script: |
            const releases = process.env.RELEASES.split(",").filter(Boolean)
            const eventName = context.eventName
            const payload = context.payload

            let runRequested = true
            let runAll = false
            let selector = ""
            let checkoutRef = context.sha

            const selectReleases = (value) => {
              const exact = []
              const byMinor = new Map()
              const lower = (value || "").toLowerCase()
              for (const release of releases) {
                const relLower = release.toLowerCase()
                const match = release.match(/^v(\d+)\.(\d+)\./)
                const minorDot = match ? (match[1] + "." + match[2]) : ""
                const minorDash = minorDot.replace(".", "-")

                if (lower.includes(relLower)) {
                  exact.push(release)
                  continue
                }

                if (
                  minorDot &&
                  (lower.includes(minorDot) || lower.includes(minorDash)) &&
                  !byMinor.has(minorDot)
                ) {
                  // keep first release per minor as "latest" (releases are listed newest first)
                  byMinor.set(minorDot, release)
                }
              }
              if (exact.length > 0) {
                return exact
              }
              return Array.from(byMinor.values())
            }

            if (eventName === "pull_request") {
              const pr = payload.pull_request
              selector = (pr.head.ref || "") + " " + (pr.title || "")
              checkoutRef = pr.head.sha || context.sha
            } else if (eventName === "issue_comment") {
              const issue = payload.issue
              const body = (payload.comment?.body || "").trim()

              if (!issue?.pull_request) {
                runRequested = false
              } else if (!/^\/test(\s|$)/.test(body)) {
                runRequested = false
              } else {
                const { owner, repo } = context.repo
                const pullNumber = issue.number
                const { data: pr } = await github.rest.pulls.get({
                  owner,
                  repo,
                  pull_number: pullNumber,
                })
                checkoutRef = pr.head.sha
                // comment selector can include one or multiple versions, e.g. "/test 1.28 1.29".
                selector = body.replace(/^\/test(\s+)?/, "")
              }
            } else {
              runAll = true
            }

            let selected = []
            if (runRequested) {
              if (runAll) {
                selected = releases
              } else {
                selected = selectReleases(selector)
                if (selected.length === 0) {
                  runAll = true
                  selected = releases
                }
              }
            }

            const selectedReleases = selected.length ? ("," + selected.join(",") + ",") : ""

            core.setOutput("run_requested", runRequested ? "true" : "false")
            core.setOutput("run_all", runAll ? "true" : "false")
            core.setOutput("selected_releases", selectedReleases)
            core.setOutput("checkout_ref", checkoutRef)
            core.info(
              "run_requested=" + runRequested +
              " run_all=" + runAll +
              " selected_releases=" + selectedReleases +
              " checkout_ref=" + checkoutRef
            )

  Patch:
    needs:
      - Select-Releases
    if: \${{ needs.Select-Releases.outputs.run_requested == 'true' }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          ref: \${{ needs.Select-Releases.outputs.checkout_ref }}
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

EOF

for release in ${RELEASES}; do
  name=${release//\./\-}
  cat <<EOF
  Test-${name}:
    needs:
      - Patch
      - Select-Releases
    if: \${{ needs.Select-Releases.outputs.run_requested == 'true' && (needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},')) }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          ref: \${{ needs.Select-Releases.outputs.checkout_ref }}
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
    if: \${{ needs.Select-Releases.outputs.run_requested == 'true' && (needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},')) }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          ref: \${{ needs.Select-Releases.outputs.checkout_ref }}
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
    if: \${{ needs.Select-Releases.outputs.run_requested == 'true' && (needs.Select-Releases.outputs.run_all == 'true' || contains(needs.Select-Releases.outputs.selected_releases, ',${release},')) }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          ref: \${{ needs.Select-Releases.outputs.checkout_ref }}
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
