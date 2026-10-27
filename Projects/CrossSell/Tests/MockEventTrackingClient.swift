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
    /// Every `setUserProperty` call in order, so a test can tell "cleared" from "never touched".
    private(set) var userPropertyChanges = [(name: String, value: String?)]()

    struct TrackedEvent: Equatable {
        let name: String
        let parameters: [String: String]
    }

    /// The latest value set per property; a key is absent until the property has been set at all.
    var userProperties: [String: String?] {
        var properties: [String: String?] = [:]
        for change in userPropertyChanges {
            properties[change.name] = change.value
        }
        return properties
    }

    func setCollectionEnabled(_ enabled: Bool) {}

    func trackEvent(name: String, parameters: [String: Any]?) {
        trackedEvents.append(.init(name: name, parameters: (parameters ?? [:]).mapValues { "\($0)" }))
    }

    func trackScreen(name: String, parameters: [String: Any]?) {}

    func setUserId(_ userId: String?) {}

    func setUserProperty(name: String, value: String?) {
        userPropertyChanges.append((name, value))
    }
}
