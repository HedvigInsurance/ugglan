#!/bin/bash
set -e

# Xcode Cloud / CI runners start with a clean checkout — nuking Derived
# would only force a redundant regeneration pass, so skip it there.
if [ -z "$CI" ]; then
    rm -rf **/Derived/*
fi

scripts/githooks.sh
scripts/swiftgen.sh
scripts/codegen.sh

tuist generate

scripts/configure-embed-app-extensions.sh

