#
#function copyFramework() {
#    cp -rf "${CONFIGURATION_BUILD_DIR}/"$1.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"$1.framework
#}
#copyFramework HedvigShared
#
#rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks
#
#find "${TARGET_BUILD_DIR}" -name '*.framework' -print0 | while read -d $'\0' framework
#do
#    codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements --timestamp=none "${framework}"
#done
#
#REVEAL_APP_PATH=$(mdfind kMDItemCFBundleIdentifier="com.ittybittyapps.Reveal2" | head -n 1)
#BUILD_SCRIPT_PATH="${REVEAL_APP_PATH}/Contents/SharedSupport/Scripts/reveal_server_build_phase.sh"
#if [ "${REVEAL_APP_PATH}" -a -e "${BUILD_SCRIPT_PATH}" ]; then
#"${BUILD_SCRIPT_PATH}"
#else
#    echo "Reveal Server not loaded: Cannot find a compatible Reveal app."
#fi
