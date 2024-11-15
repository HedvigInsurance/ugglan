#!/bin/bash
set -e

rm -rf **/Derived/*

scripts/githooks.sh
arch -x86_64 scripts/translations.sh
scripts/swiftgen.sh
scripts/codegen.sh

tuist generate

scripts/fix-assets-for-swift-6.sh


scripts/configure-embed-app-extensions.sh
