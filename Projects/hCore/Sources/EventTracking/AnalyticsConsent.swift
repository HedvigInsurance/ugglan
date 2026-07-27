import Foundation

public enum AnalyticsConsent {
    public static let hasConsentedKey = "analytics_collection_has_consented"

    public static var isGiven: Bool {
        UserDefaults.standard.bool(forKey: hasConsentedKey) == true
    }

    @MainActor
    public static func give() {
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.setCollectionEnabled(true)
        UserDefaults.standard.set(true, forKey: hasConsentedKey)
    }

    @MainActor
    public static func revoke() {
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.setCollectionEnabled(false)
        UserDefaults.standard.set(false, forKey: hasConsentedKey)
    }
}
