#!/usr/bin/env bash
set -e
set -x

# The generated projects and codegen output are committed, so Xcode Cloud builds the checkout as is.

# Package.resolved isn't committed, and Xcode Cloud disables automatic package resolution by default
# ("a resolved file is required when automatic dependency resolution is disabled"). Let xcodebuild
# resolve packages from the version rules in the projects, as it did when codegen.sh ran here.
defaults write com.apple.dt.Xcode IDEPackageOnlyUseVersionsFromResolvedFile -bool NO
defaults write com.apple.dt.Xcode IDEDisableAutomaticPackageResolution -bool NO

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
