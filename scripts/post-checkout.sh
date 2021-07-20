#!/bin/bash

rm -rf **/Derived/*

scripts/githooks.sh
arch -x86_64 scripts/translations.sh
scripts/swiftgen.sh
scripts/codegen.sh

TUIST=/usr/local/bin/tuist

if [[ -e "${TUIST}" ]]; then
    /usr/local/bin/tuist generate
else
    echo "warning: Tuist is not installed, install from https://tuist.io"
fi
