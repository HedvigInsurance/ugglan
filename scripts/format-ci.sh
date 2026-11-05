#!/usr/bin/env bash
set -e
set -x

SWIFT_FORMAT_PATH=$(find . -type f -name swift-format | grep -v '.dSYM')

# Derived/ is committed generator output (swiftgen, Apollo) and must stay byte-identical to what the generators write
git diff --name-only origin/$GITHUB_BASE_REF | grep -e '\(.*\).swift$' | grep -v '/Derived/' | while read line; do
    if test -f "${line}"; then
        $SWIFT_FORMAT_PATH -i "${line}";
    fi
done