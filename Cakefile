iOSdeploymentTarget = "9.0"
currentSwiftVersion = "4.2"
companyIdentifier = "com.hedvig"
developmentTeamId = "XYZXYZ"

provProfAdHoc = "XXX"
provProfAppStore = "YYY"

project.name = "ugglan"
project.class_prefix = "CMN"
project.organization = "Hedvig AB"

project.all_configurations.each do |configuration|
    configuration.settings["ENABLE_BITCODE"] = "YES"

    configuration.settings["SDKROOT"] = "iphoneos"
    configuration.settings["GCC_DYNAMIC_NO_PIC"] = "NO"
    configuration.settings["OTHER_CFLAGS"] = "$(inherited) -DNS_BLOCK_ASSERTIONS=1"
    configuration.settings["GCC_C_LANGUAGE_STANDARD"] = "gnu99"
    configuration.settings["CLANG_ENABLE_MODULES"] = "YES"
    configuration.settings["CLANG_ENABLE_OBJC_ARC"] = "YES"
    configuration.settings["ENABLE_NS_ASSERTIONS"] = "NO"
    configuration.settings["ENABLE_STRICT_OBJC_MSGSEND"] = "YES"
    configuration.settings["CLANG_WARN_EMPTY_BODY"] = "YES"
    configuration.settings["CLANG_WARN_BOOL_CONVERSION"] = "YES"
    configuration.settings["CLANG_WARN_CONSTANT_CONVERSION"] = "YES"
    configuration.settings["GCC_WARN_64_TO_32_BIT_CONVERSION"] = "YES"
    configuration.settings["CLANG_WARN_INT_CONVERSION"] = "YES"
    configuration.settings["GCC_WARN_ABOUT_RETURN_TYPE"] = "YES_ERROR"
    configuration.settings["GCC_WARN_UNINITIALIZED_AUTOS"] = "YES_AGGRESSIVE"
    configuration.settings["CLANG_WARN_UNREACHABLE_CODE"] = "YES"
    configuration.settings["GCC_WARN_UNUSED_FUNCTION"] = "YES"
    configuration.settings["GCC_WARN_UNUSED_VARIABLE"] = "YES"
    configuration.settings["CLANG_WARN_DIRECT_OBJC_ISA_USAGE"] = "YES_ERROR"
    configuration.settings["CLANG_WARN__DUPLICATE_METHOD_MATCH"] = "YES"
    configuration.settings["GCC_WARN_UNDECLARED_SELECTOR"] = "YES"
    configuration.settings["CLANG_WARN_OBJC_ROOT_CLASS"] = "YES_ERROR"

    configuration.settings["CURRENT_PROJECT_VERSION"] = "1" # just default non-empty value

    configuration.settings["DEFINES_MODULE"] = "YES" # http://stackoverflow.com/a/27251979

    configuration.settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"

    configuration.settings["CLANG_WARN_INFINITE_RECURSION"] = "YES" # Xcode 8
    configuration.settings["CLANG_WARN_SUSPICIOUS_MOVE"] = "YES" # Xcode 8
    configuration.settings["ENABLE_STRICT_OBJC_MSGSEND"] = "YES" # Xcode 8
    configuration.settings["GCC_NO_COMMON_BLOCKS"] = "YES"
    configuration.settings["ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES"] = "$(inherited)" # "YES"

    configuration.settings["SWIFT_VERSION"] = currentSwiftVersion

    if configuration.name == "RC" || configuration.name == "AppStore"

        configuration.settings["DEBUG_INFORMATION_FORMAT"] = "dwarf-with-dsym"
        configuration.settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Owholemodule" # Xcode 8

    end
end

target do |target|

    target.name = project.name
    target.language = :swift
    target.type = :application
    target.platform = :ios
    target.deployment_target = iOSdeploymentTarget

    target.all_configurations.each do |configuration|
        configuration.product_bundle_identifier = companyIdentifier + "." + target.name
        configuration.supported_devices = :universal
        configuration.settings["INFOPLIST_FILE"] = "Info/" + target.name + ".plist"
        configuration.settings["PRODUCT_NAME"] = "$(TARGET_NAME)"

        configuration.settings["LIBRARY_SEARCH_PATHS"] = "$(inherited) $(SRCROOT)/Lib/**"
        configuration.settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
        configuration.settings["OTHER_LDFLAGS"] = "$(inherited) -ObjC"

        configNameFlag = "CONFIG_" + configuration.name.upcase
        configuration.settings["GCC_PREPROCESSOR_DEFINITIONS"] = "$(inherited) " + configNameFlag + "=1" # Obj-C support
        configuration.settings["OTHER_SWIFT_FLAGS"] = "$(inherited) -D" + configNameFlag # Swift support

        configuration.settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "iPhone Developer"
        configuration.settings["DEVELOPMENT_TEAM"] = developmentTeamId
    end

    target.include_files = ["Src/**/*.*"]

end