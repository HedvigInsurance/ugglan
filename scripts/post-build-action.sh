rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks/FirebaseAnalytics.framework
rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks/GoogleAppMeasurement.framework
mv -iv -- "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks/Adyen3DS2.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"Adyen3DS2.framework
mv -iv -- "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks/Shake.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"Shake.framework
rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks

find "${TARGET_BUILD_DIR}" -name '*.framework' -print0 | while read -d $'\0' framework
do
    codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements --timestamp=none "${framework}"
done