#!/usr/bin/env bash
set -e
brew install mise
TUIST_VERSION=$(cat .tuist-version)
mise install tuist@"$TUIST_VERSION"
mise use -g tuist@"$TUIST_VERSION"
# Make tuist visible to subsequent GitHub Actions steps
if [ -n "$GITHUB_PATH" ]; then
    echo "$HOME/.local/share/mise/shims" >> "$GITHUB_PATH"
fi
