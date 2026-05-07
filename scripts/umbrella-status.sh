#!/usr/bin/env bash
# Prints whether Ugglan is currently set up to consume umbrella locally
# (HedvigShared.framework rebuilt from sibling android/ on every Xcode build)
# or from the published Swift Package pinned in Project+DependenciesTemplate.swift.
# Prompts to switch — `y` runs the opposite mode-switch script, anything else exits.

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKER="$UGGLAN_ROOT/.local-umbrella-path"

if [ -f "$MARKER" ]; then
    echo "Umbrella mode: local"
    echo "  Marker: $MARKER"
    SWITCH_SCRIPT="scripts/use-released-umbrella.sh"
    OTHER_MODE="released"
else
    PINNED=$(grep -oE 'umbrella\.git", \.exact\("[^"]+"' \
        "$UGGLAN_ROOT/Tuist/ProjectDescriptionHelpers/Project+DependenciesTemplate.swift" 2>/dev/null \
        | grep -oE '0\.0\.[0-9]+' | head -1)
    echo "Umbrella mode: released"
    echo "  Pinned: ${PINNED:-(not found)}"
    SWITCH_SCRIPT="scripts/use-local-umbrella.sh"
    OTHER_MODE="local"
fi

echo
read -r -p "Switch to $OTHER_MODE mode? [y/N] " REPLY
if [ "$REPLY" = "y" ]; then
    cd "$UGGLAN_ROOT"
    exec "$SWITCH_SCRIPT"
fi
