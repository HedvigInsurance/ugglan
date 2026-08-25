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

    /// Returns consent to the undecided state (nil), unlike `revoke()` which stores an explicit "no".
    @MainActor
    public static func reset() {
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.setCollectionEnabled(false)
        UserDefaults.standard.removeObject(forKey: hasConsentedKey)
    }
}

extension UserDefaults {
    @objc(analytics_collection_has_consented)
    public dynamic var analyticsConsentDecision: NSNumber? {
        object(forKey: AnalyticsConsent.hasConsentedKey) as? NSNumber
    }
}
