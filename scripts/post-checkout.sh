#!/bin/bash
set -e

scripts/githooks.sh
scripts/swiftgen.sh
scripts/codegen.sh

tuist generate

