#!/usr/bin/env bash
set -e
set -x

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise --version
mise install tuist@4.50.2

cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi
mise use -g tuist
scripts/post-checkout.sh


