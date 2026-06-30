import hCore

@MainActor
struct EventTrackingClientDemo: EventTrackingClient {
    func setCollectionEnabled(_ enabled: Bool) {}

    func trackEvent(name: String, parameters: [String: Any]?) {}

    func trackScreen(name: String, parameters: [String: Any]?) {}

    func setUserId(_ userId: String?) {}

    func setUserProperty(name: String, value: String?) {}
}
