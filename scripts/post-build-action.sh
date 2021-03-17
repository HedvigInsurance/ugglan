rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/*.framework"/Frameworks/FirebaseAnalytics.framework
rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/*.framework"/Frameworks/GoogleAppMeasurement.framework
mv -iv -- "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"*".framework"/Frameworks/Adyen3DS2.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"Adyen3DS2.framework
rm -rf "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/*.framework"/Frameworks
