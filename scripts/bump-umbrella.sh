#!/usr/bin/env bash
# Fetch the latest umbrella release tag from GitHub and rewrite the pinned
# version in Project+DependenciesTemplate.swift. Run this to bump the iOS
# app to the most recent published HedvigShared framework without hand-editing
# the version string.

set -euo pipefail

UGGLAN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$UGGLAN_ROOT/Tuist/ProjectDescriptionHelpers/Project+DependenciesTemplate.swift"
MARKER="$UGGLAN_ROOT/.local-umbrella-path"
REPO="HedvigInsurance/umbrella"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "error: template not found at $TEMPLATE" >&2
    exit 1
fi

echo "==> Fetching latest release from github.com/$REPO"
if command -v gh >/dev/null 2>&1; then
    LATEST_TAG="$(gh api "repos/$REPO/releases/latest" --jq .tag_name)"
else
    LATEST_TAG="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
        | head -n1)"
fi

if [[ -z "${LATEST_TAG:-}" ]]; then
    echo "error: could not determine latest release tag" >&2
    exit 1
fi

CURRENT_TAG="$(sed -nE 's/.*umbrella\.git", \.exact\("([^"]+)"\).*/\1/p' "$TEMPLATE" | head -n1)"
if [[ -z "$CURRENT_TAG" ]]; then
    echo "error: could not find pinned umbrella version in $TEMPLATE" >&2
    exit 1
fi

echo "==> Current: $CURRENT_TAG"
echo "==> Latest:  $LATEST_TAG"

if [[ "$CURRENT_TAG" == "$LATEST_TAG" ]]; then
    echo "==> Already up to date."
    exit 0
fi

sed -i '' -E "s|(umbrella\.git\", \.exact\(\")[^\"]+(\"\))|\1${LATEST_TAG}\2|" "$TEMPLATE"
echo "==> Updated $TEMPLATE"
echo "    $CURRENT_TAG -> $LATEST_TAG"

if [[ -f "$MARKER" ]]; then
    echo
    echo "note: $MARKER exists, so tuist generate will keep using the local XCFramework."
    echo "      Run scripts/use-released-umbrella.sh once you're ready to consume the bumped package."
fi
