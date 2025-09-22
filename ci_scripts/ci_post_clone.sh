#!/usr/bin/env bash
set -e
set -x

curl https://mise.jdx.dev/install.sh | sh
echo "eval \"\$(/Users/local/.local/bin/mise activate --shims zsh)\"" >> "/Users/local/.zshrc"
echo "version:"
mise --version
mise install tuist@4.50.2

cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi

scripts/post-checkout.sh


