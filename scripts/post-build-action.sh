
    function copyFramework() {
        cp -rf "${CONFIGURATION_BUILD_DIR}/"$1.framework "${TARGET_BUILD_DIR}/${TARGET_NAME}.app/Frameworks/"$1.framework
    }

    copyFramework authlib
