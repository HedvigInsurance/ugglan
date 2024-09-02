import StoreContainer
import XCTest
import hCore

@testable import Profile

final class MemberSubscriptionPreferenceViewModelTests: XCTestCase {
    weak var sut: MockProfileService?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testToggleSubscriptionSuccess() async {
        let mockService = MockData.createMockProfileService(
            subscriptionPreferenceUpdate: { _ in }
        )

        self.sut = mockService

        let model = MemberSubscriptionPreferenceViewModel()
        await model.toogleSubscription()
        await waitUntil(description: "check isUnsubscribed") {
            model.isLoading == false && model.isUnsubscribed == false
        }
    }

    func testToggleSubscriptionFailure() async {
        let mockService = MockData.createMockProfileService(
            subscriptionPreferenceUpdate: { _ in
                throw ProfileError.error(message: "error")
            }
        )

        self.sut = mockService

        let model = MemberSubscriptionPreferenceViewModel()
        await model.toogleSubscription()

        assert(model.isLoading == false)
        assert(model.isUnsubscribed == false)
    }
}
