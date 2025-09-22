#!/usr/bin/env bash
set -e
set -x

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise install tuist@4.50.2
eval "$(mise activate bash --shims)" # Addds the activated tools to $PATH
echo "👉 Setting mise globally:"
mise use -g tuist

cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js using Homebrew ====="
  brew install node

  echo "===== Installing Yarn using Homebrew ====="
  brew install yarn
fi
scripts/post-checkout.sh


