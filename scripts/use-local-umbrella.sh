#!/usr/bin/env bash
# Switch Ugglan to local-umbrella mode: gradle pre-build phase rebuilds
# HedvigShared.framework from the sibling android/ repo on every Xcode build.
# Requires android/ and ugglan/ to be siblings.

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_REPO="$UGGLAN_ROOT/../android"

if [[ ! -d "$ANDROID_REPO" ]]; then
    echo "error: expected android repo at $ANDROID_REPO" >&2
    exit 1
fi

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

touch "$UGGLAN_ROOT/.local-umbrella"
echo "==> Marker created at $UGGLAN_ROOT/.local-umbrella"

( cd "$UGGLAN_ROOT" && scripts/post-checkout.sh )
echo "==> Done. Open Ugglan.xcworkspace and build."
echo "    Run scripts/use-released-umbrella.sh to revert."
