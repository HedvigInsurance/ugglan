import ProjectDescription

extension DefaultSettings {
    // Tuist's recommended app settings write ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor into
    // the target, which beats the blank value in iOS-Application.xcconfig. No catalog defines that colorset, so
    // actool warns on every app and Example build. Leaving the setting out lets the xcconfig win.
    public static let app: DefaultSettings = .recommended(excluding: ["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"])
}
