#!/usr/bin/env bash
# Revert from local-umbrella mode back to the published Swift Package pinned in
# Project+DependenciesTemplate.swift. Run before opening a PR.

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# DerivedData must be wiped on every mode switch; mixing artifacts from both modes
# produces silent signature corruption that iOS rejects on install.
if pgrep -x Xcode >/dev/null; then
    echo "error: Xcode is running. Close it before switching modes." >&2
    exit 1
fi
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
if compgen -G "$DERIVED_DATA/Ugglan-*" > /dev/null; then
    echo "==> Wiping $DERIVED_DATA/Ugglan-*"
    rm -rf "$DERIVED_DATA"/Ugglan-*
fi

rm -f "$UGGLAN_ROOT/.local-umbrella-path"
( cd "$UGGLAN_ROOT" && scripts/post-checkout.sh )
echo "==> Reverted to released umbrella."
