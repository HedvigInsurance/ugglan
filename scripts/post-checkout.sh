#!/bin/bash
set -e

rm -rf **/Derived/*

scripts/githooks.sh
arch -x86_64 scripts/translations.sh
scripts/swiftgen.sh
scripts/codegen.sh

if ! command -v <the_command> &> /dev/null
then
    echo "warning: Carthage is not installed, trying to install with brew"
    brew install carthage
fi

tuist fetch

TUIST=/usr/local/bin/tuist

if [[ -e "${TUIST}" ]]; then
    /usr/local/bin/tuist fetch
    /usr/local/bin/tuist generate
else
    echo "error: Tuist is not installed, install from https://tuist.io"
fi
