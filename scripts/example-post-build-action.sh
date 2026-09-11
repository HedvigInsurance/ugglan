#!/bin/bash
# Post-build step for *Example apps that transitively link RiveRuntime.
# Tuist doesn't auto-embed the SPM binary framework, so the example crashes at
# launch with "Library not loaded: @rpath/RiveRuntime.framework/RiveRuntime".
# Mirrors the RiveRuntime part of scripts/post-build-action.sh used by the Ugglan app.

APP_BUNDLE="${TARGET_BUILD_DIR}/${TARGET_NAME}.app"

if [ -d "${CONFIGURATION_BUILD_DIR}/RiveRuntime.framework" ]; then
    mkdir -p "${APP_BUNDLE}/Frameworks"
    cp -rf "${CONFIGURATION_BUILD_DIR}/RiveRuntime.framework" "${APP_BUNDLE}/Frameworks/RiveRuntime.framework"
fi

# Same cleanup as the app: static umbrella wrapper and nested Frameworks/ dirs.
rm -rf "${APP_BUNDLE}/Frameworks/HedvigShared.framework"
rm -rf "${APP_BUNDLE}/Frameworks/"*".framework"/Frameworks

find "${APP_BUNDLE}/Frameworks" -maxdepth 1 -name '*.framework' -print0 | while read -d $'\0' framework
do
    codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY:--}" --preserve-metadata=identifier,entitlements --timestamp=none "${framework}"
done
