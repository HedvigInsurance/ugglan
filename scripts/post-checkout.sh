#!/bin/bash
set -e

rm -rf **/Derived/*

scripts/githooks.sh
scripts/swiftgen.sh
scripts/codegen.sh

tuist generate

scripts/configure-embed-app-extensions.sh

