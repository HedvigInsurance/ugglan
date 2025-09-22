#!/usr/bin/env bash
set -e
set -x
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --ignore-dependencies tuist@4.50.2


cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi

scripts/post-checkout.sh


