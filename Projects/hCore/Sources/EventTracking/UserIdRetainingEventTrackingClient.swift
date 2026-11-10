import Foundation

@MainActor
public final class UserIdRetainingEventTrackingClient: EventTrackingClient {
    private let client: EventTrackingClient
    private var userId: String?

    public init(_ client: EventTrackingClient) {
        self.client = client
    }

    public func setCollectionEnabled(_ enabled: Bool) {
        client.setCollectionEnabled(enabled)
        if enabled, let userId {
            client.setUserId(userId)
        }
    }

    public func trackEvent(name: String, parameters: [String: Any]?) {
        client.trackEvent(name: name, parameters: parameters)
    }

    public func trackScreen(name: String, parameters: [String: Any]?) {
        client.trackScreen(name: name, parameters: parameters)
    }

    public func setUserId(_ userId: String?) {
        self.userId = userId
        client.setUserId(userId)
    }

    public func setUserProperty(name: String, value: String?) {
        client.setUserProperty(name: name, value: value)
    }
}
