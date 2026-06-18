#!/usr/bin/env bash
set -e
set -x

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
TUIST_VERSION=$(cat "$CI_PRIMARY_REPOSITORY_PATH/.tuist-version")
mise install tuist@"$TUIST_VERSION"
eval "$(mise activate bash --shims)" # Addds the activated tools to $PATH
echo "👉 Setting mise globally:"
mise use -g tuist@"$TUIST_VERSION"

cd $CI_PRIMARY_REPOSITORY_PATH;

if [ "${DATADOG_API_KEY+x}" ]; then
  echo "===== Installing Node.js via mise ====="
  NODE_VERSION=22
  mise install node@$NODE_VERSION
  mise use -g node@$NODE_VERSION
fi
scripts/post-checkout.sh


