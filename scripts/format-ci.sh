#!/usr/bin/env bash
set -e
set -x

SWIFT_FORMAT_PATH=$(find . -type f -name swift-format | grep -v '.dSYM')

git diff --name-only origin/$GITHUB_BASE_REF | grep -e '\(.*\).swift$' | while read line; do
    if test -f "${line}"; then
        $SWIFT_FORMAT_PATH -i "${line}";
    fi
done