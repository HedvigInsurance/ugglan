
function copyFramework() {
    cp -rf "${CONFIGURATION_BUILD_DIR}/"$1.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"$1.framework
}
copyFramework HedvigShared
copyFramework RiveRuntime

# Compose Multiplatform's iOS resource reader uses Bundle.main and looks for resources
# at <App>.app/compose-resources/composeResources/... Two cases land them in the wrong
# place by default and we lift them out here.
#
#   Local mode: gradle's pre-build phase runs from CoreDependencies' target context, so
#   Xcode's "Copy Bundle Resources" packages compose-resources/ inside
#   CoreDependencies.framework. The directory already has the compose-resources/
#   prefix; copy it as-is to the app bundle root.
#
#   Released mode: SPM extracts the published XCFramework's slice into
#   HedvigShared.framework. Resources inside it are at composeResources/... (no
#   compose-resources/ parent), so synthesize the parent on copy.
APP_BUNDLE="${TARGET_BUILD_DIR}/${TARGET_NAME}.app"
LOCAL_RESOURCES="${APP_BUNDLE}/Frameworks/CoreDependencies.framework/compose-resources"
RELEASED_RESOURCES="${APP_BUNDLE}/Frameworks/HedvigShared.framework/composeResources"

rm -rf "${APP_BUNDLE}/compose-resources"
if [ -d "$LOCAL_RESOURCES" ]; then
    cp -rf "$LOCAL_RESOURCES" "${APP_BUNDLE}/compose-resources"
elif [ -d "$RELEASED_RESOURCES" ]; then
    mkdir -p "${APP_BUNDLE}/compose-resources"
    cp -rf "$RELEASED_RESOURCES" "${APP_BUNDLE}/compose-resources/composeResources"
fi

rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks

find "${TARGET_BUILD_DIR}" -name '*.framework' -print0 | while read -d $'\0' framework
do
    codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements --timestamp=none "${framework}"
done

REVEAL_APP_PATH=$(mdfind kMDItemCFBundleIdentifier="com.ittybittyapps.Reveal2" | head -n 1)
BUILD_SCRIPT_PATH="${REVEAL_APP_PATH}/Contents/SharedSupport/Scripts/reveal_server_build_phase.sh"
if [ "${REVEAL_APP_PATH}" -a -e "${BUILD_SCRIPT_PATH}" ]; then
"${BUILD_SCRIPT_PATH}"
else
    echo "Reveal Server not loaded: Cannot find a compatible Reveal app."
fi
