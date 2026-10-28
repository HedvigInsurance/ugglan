import hCore

extension MockData {
    @discardableResult
    static func createMockEventTrackingClient() -> MockEventTrackingClient {
        let client = MockEventTrackingClient()
        Dependencies.shared.add(module: Module { () -> EventTrackingClient in client })
        return client
    }
}

class MockEventTrackingClient: EventTrackingClient {
    var trackedEvents = [TrackedEvent]()

    struct TrackedEvent: Equatable {
        let name: String
        let parameters: [String: String]
    }

    func setCollectionEnabled(_ enabled: Bool) {}

    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append(.init(name: name, parameters: (parameters ?? [:]).mapValues { "\($0)" }))
    }

    func trackScreen(name: String, parameters: [String: Any]?) {}

    func setUserId(_ userId: String?) {}

    func setUserProperty(name: String, value: String?) {}
}
