import ProjectDescription

extension DefaultSettings {
    // Tuist's recommended app settings write ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor into
    // the target, which beats the blank value in iOS-Application.xcconfig. No catalog defines that colorset, so
    // actool warns on every app and Example build. Leaving the setting out lets the xcconfig win.
    public static let app: DefaultSettings = .recommended(excluding: ["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"])
}

extension SettingsDictionary {
    // Targets with `infoPlist: nil` get no Info.plist file from Tuist; Xcode generates one at build time from
    // build settings instead, so no Derived/InfoPlists file has to be committed for them.
    // MARKETING_VERSION keeps CFBundleShortVersionString (1.0, as in Tuist's default plist): App Store Connect
    // rejects embedded frameworks without it.
    public static let generatedInfoPlist: SettingsDictionary = [
        "GENERATE_INFOPLIST_FILE": "YES",
        "MARKETING_VERSION": "1.0",
    ]

    // Tuist's default Debug settings write SWIFT_ACTIVE_COMPILATION_CONDITIONS as a list, which Xcode rewrites into
    // a single string whenever it saves a project. Writing the string form up front keeps those saves diff-free.
    // No $(inherited): Tuist would merge that back into its list. DEBUG is all Debug.xcconfig sets anyway.
    public static let debugCompilationConditions: SettingsDictionary = [
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG"
    ]
}
