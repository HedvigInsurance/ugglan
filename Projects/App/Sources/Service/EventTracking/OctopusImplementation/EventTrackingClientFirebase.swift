import FirebaseAnalytics
import hCore

@MainActor
struct EventTrackingClientFirebase: EventTrackingClient {
    func setCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    func trackEvent(name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    func trackScreen(name: String, parameters: [String: Any]?) {
        var params = parameters ?? [:]
        params[AnalyticsParameterScreenName] = name
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }

    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }

    func setUserProperty(name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
    }
}
