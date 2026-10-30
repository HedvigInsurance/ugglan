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

    func setCollectionEnabled(_: Bool) {
        // Not asserted in tests
    }

    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append(.init(name: name, parameters: (parameters ?? [:]).mapValues { "\($0)" }))
    }

    func trackScreen(name _: String, parameters _: [String: Any]?) {
        // Not asserted in tests
    }

    func setUserId(_: String?) {
        // Not asserted in tests
    }

    func setUserProperty(name _: String, value _: String?) {
        // Not asserted in tests
    }
}
