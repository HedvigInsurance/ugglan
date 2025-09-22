#!/usr/bin/env bash
set -e
set -x
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ENV_FILTERING=1
export HOMEBREW_FORCE_BREWED_CURL=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_DEVELOPER=1
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
brew tap tuist/tuist
brew install --formula tuist@4.50.2

cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi

scripts/post-checkout.sh


