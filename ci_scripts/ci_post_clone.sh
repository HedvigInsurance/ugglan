#!/usr/bin/env bash
set -e
set -x

# The generated projects and codegen output are committed, so Xcode Cloud builds the checkout as is.
# mise is only needed for Node.js, which ci_post_xcodebuild.sh uses to upload symbols to Datadog.
if [ "${DATADOG_API_KEY+x}" ]; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
  eval "$(mise activate bash --shims)" # Adds the activated tools to $PATH

  echo "===== Installing Node.js via mise ====="
  NODE_VERSION=22
  mise install node@$NODE_VERSION
  mise use -g node@$NODE_VERSION
fi
