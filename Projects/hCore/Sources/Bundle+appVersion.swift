import Foundation

extension Bundle {
    public var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0" }
    public var buildVersion: Int32 { Int32(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0") ?? 0 }
}
