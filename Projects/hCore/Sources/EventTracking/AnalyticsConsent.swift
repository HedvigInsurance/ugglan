import Foundation

public enum AnalyticsConsent {
    private static let hasConsentedKey = "analytics_collection_has_consented"

    public static var isGiven: Bool {
        UserDefaults.standard.object(forKey: hasConsentedKey) != nil
    }

    public static func give() {
        UserDefaults.standard.set(true, forKey: hasConsentedKey)
    }
}
