
APP_BUNDLE="${TARGET_BUILD_DIR}/${TARGET_NAME}.app"

# --- Frameworks: lay out what ships in <App>.app/Frameworks/ ---

# Bring in RiveRuntime (Tuist doesn't auto-embed it).
function copyFramework() {
    cp -rf "${CONFIGURATION_BUILD_DIR}/"$1.framework "${APP_BUNDLE}/Frameworks/"$1.framework
}
copyFramework RiveRuntime

# Remove HedvigShared.framework. `:umbrella` is isStatic=true; its Kotlin symbols
# are already statically linked into AppDependencies.framework, and nothing has
# an LC_LOAD_DYLIB for HedvigShared. Leaving the static-archive wrapper in
# Frameworks/ produces a `bundle with generic` (CodeDirectory v=20200) signature
# that iOS 16.7+ rejects on install with 0xE8008029.
rm -rf "${APP_BUNDLE}/Frameworks/HedvigShared.framework"

# Strip nested Frameworks/ directories some embedded frameworks ship with.
rm -rf "${APP_BUNDLE}/Frameworks/"*".framework"/Frameworks

# --- Re-sign every framework now that the bundle layout is final ---

# Scope to this target's own bundle. TARGET_BUILD_DIR is shared by every target, so scanning it
# re-signs other targets' frameworks while they're being built/signed in parallel, which races
# codesign on the same binary and intermittently fails with "<Name>.cstemp couldn't be opened".
find "${APP_BUNDLE}/Frameworks" -maxdepth 1 -name '*.framework' -print0 | while read -d $'\0' framework
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
