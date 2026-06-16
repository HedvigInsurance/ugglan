import hCore

@MainActor
struct EventTrackingClientDemo: EventTrackingClient {
    func setCollectionEnabled(_ enabled: Bool) {}

    func trackEvent(name: String, parameters: [String: Any]?) {
        log.info("[EventTracking demo] event=\(name) params=\(parameters ?? [:])", error: nil, attributes: nil)
    }

    func trackScreen(name: String, parameters: [String: Any]?) {
        log.info("[EventTracking demo] screen=\(name) params=\(parameters ?? [:])", error: nil, attributes: nil)
    }

    func setUserId(_ userId: String?) {
        log.info("[EventTracking demo] setUserId=\(userId ?? "nil")", error: nil, attributes: nil)
    }

    func setUserProperty(name: String, value: String?) {
        log.info("[EventTracking demo] setUserProperty \(name)=\(value ?? "nil")", error: nil, attributes: nil)
    }
}
