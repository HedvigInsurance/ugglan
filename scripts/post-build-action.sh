
function copyFramework() {
    cp -rf "${CONFIGURATION_BUILD_DIR}/"$1.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"$1.framework
}
copyFramework RiveRuntime

APP_BUNDLE="${TARGET_BUILD_DIR}/${TARGET_NAME}.app"

# Remove HedvigShared.framework from the bundle. `:umbrella` is isStatic=true; its
# Kotlin symbols are already statically linked into CoreDependencies.framework, and
# nothing has an LC_LOAD_DYLIB for HedvigShared. Leaving the static-archive wrapper
# in Frameworks/ produces a `bundle with generic` (CodeDirectory v=20200) signature
# that iOS 16.7+ rejects on install with 0xE8008029.
rm -rf "${APP_BUNDLE}/Frameworks/HedvigShared.framework"

# Compose Multiplatform's iOS resource reader uses Bundle.main, expecting resources
# at <App>.app/compose-resources/composeResources/...
#   Local mode  → resources are inside CoreDependencies.framework (with the
#                 compose-resources/ prefix). Move (not copy) so the framework's
#                 sealed file list matches its on-disk contents.
#   Released mode → resources are inside the SPM-extracted HedvigShared.framework
#                   in ${CONFIGURATION_BUILD_DIR}. Copy them, synthesizing the
#                   compose-resources/ parent.
LOCAL_RESOURCES="${APP_BUNDLE}/Frameworks/CoreDependencies.framework/compose-resources"
RELEASED_RESOURCES_SRC="${CONFIGURATION_BUILD_DIR}/HedvigShared.framework/composeResources"

rm -rf "${APP_BUNDLE}/compose-resources"
if [ -d "$LOCAL_RESOURCES" ]; then
    mv "$LOCAL_RESOURCES" "${APP_BUNDLE}/compose-resources"
elif [ -d "$RELEASED_RESOURCES_SRC" ]; then
    mkdir -p "${APP_BUNDLE}/compose-resources"
    cp -rf "$RELEASED_RESOURCES_SRC" "${APP_BUNDLE}/compose-resources/composeResources"
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
