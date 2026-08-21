import Environment
import Foundation
import hCore

extension Localization.Locale {
    /// Locale-specific path segment for the privacy policy page.
    var privacyPolicyPath: String {
        switch self {
        case .sv_SE: return "personuppgifter"
        case .en_SE: return "privacy-policy"
        }
    }

    /// Fully-resolved privacy policy URL for the current environment and locale.
    var privacyPolicyURL: URL {
        Environment.current.webBaseURL
            .appendingPathComponent("\(webPath)/hedvig/\(privacyPolicyPath)")
    }
}
