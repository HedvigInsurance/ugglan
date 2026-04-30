#!/usr/bin/env bash
# Revert from a locally-built umbrella XCFramework back to the published package
# pinned in Project+DependenciesTemplate.swift. Run this when you're done iterating.

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
rm -f "$UGGLAN_ROOT/.local-umbrella-path"
( cd "$UGGLAN_ROOT" && tuist generate )
echo "==> Reverted to released umbrella."
