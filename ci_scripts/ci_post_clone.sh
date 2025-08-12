#!/usr/bin/env bash
set -e
set -x

brew tap tuist/tuist
brew install --formula tuist@4.50.2

cd $CI_PRIMARY_REPOSITORY_PATH;

if [[ -n "${DATADOG_API_KEY:-}" ]]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi

scripts/post-checkout.sh


