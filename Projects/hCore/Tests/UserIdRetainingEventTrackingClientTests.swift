import Testing

@testable import hCore

@MainActor
final class UserIdRetainingEventTrackingClientTests {
    private let firebase = RecordingEventTrackingClient()
    private lazy var sut = UserIdRetainingEventTrackingClient(firebase)

    @Test
    func userIdSetWhileCollectionIsOffIsAppliedAgainWhenCollectionTurnsOn() {
        sut.setCollectionEnabled(false)
        sut.setUserId("member")
        firebase.calls = []

        sut.setCollectionEnabled(true)

        #expect(firebase.calls == [.collectionEnabled(true), .userId("member")])
    }

    @Test
    func clearedUserIdIsNotAppliedAgain() {
        sut.setUserId("member")
        sut.setUserId(nil)
        firebase.calls = []

        sut.setCollectionEnabled(true)

        #expect(firebase.calls == [.collectionEnabled(true)])
    }

    @Test
    func turningCollectionOffAppliesNothing() {
        sut.setUserId("member")
        firebase.calls = []

        sut.setCollectionEnabled(false)

        #expect(firebase.calls == [.collectionEnabled(false)])
    }

    @Test
    func everyCallReachesTheWrappedClient() {
        sut.setUserId("member")
        sut.trackEvent(name: "event", parameters: nil)
        sut.trackScreen(name: "screen", parameters: nil)
        sut.setUserProperty(name: "property", value: "value")

        #expect(firebase.calls == [.userId("member"), .event("event"), .screen("screen"), .userProperty("property")])
    }
}

@MainActor
private final class RecordingEventTrackingClient: EventTrackingClient {
    enum Call: Equatable {
        case collectionEnabled(Bool)
        case userId(String?)
        case event(String)
        case screen(String)
        case userProperty(String)
    }

    var calls: [Call] = []

    func setCollectionEnabled(_ enabled: Bool) { calls.append(.collectionEnabled(enabled)) }
    func trackEvent(name: String, parameters _: [String: Any]?) { calls.append(.event(name)) }
    func trackScreen(name: String, parameters _: [String: Any]?) { calls.append(.screen(name)) }
    func setUserId(_ userId: String?) { calls.append(.userId(userId)) }
    func setUserProperty(name: String, value _: String?) { calls.append(.userProperty(name)) }
}
