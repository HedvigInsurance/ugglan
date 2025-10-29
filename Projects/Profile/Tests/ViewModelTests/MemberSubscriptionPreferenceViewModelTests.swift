import PresentableStore
@preconcurrency import XCTest
import hCore

@testable import Profile

@MainActor
final class MemberSubscriptionPreferenceViewModelTests: XCTestCase {
    weak var sut: MockProfileService?

    override func setUp() async throws {
        UserDefaults.standard.removeObject(forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey)
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        try await Task.sleep(seconds: 0.0000001)
        XCTAssertNil(sut)
    }

    func testToggleSubscriptionSuccess() async throws {
        let mockService = MockData.createMockProfileService(
            subscriptionPreferenceUpdate: { _ in }
        )

        sut = mockService

        let model = MemberSubscriptionPreferenceViewModel()
        try await Task.sleep(seconds: 0.3)
        let currentValue = model.isUnsubscribed
        await model.toggleSubscription()
        try await Task.sleep(seconds: 0.3)
        assert(model.isLoading == false && model.isUnsubscribed == !currentValue)
    }

    func testToggleSubscriptionFailure() async {
        let mockService = MockData.createMockProfileService(
            subscriptionPreferenceUpdate: { _ in
                throw ProfileError.error(message: "error")
            }
        )

        sut = mockService

        let model = MemberSubscriptionPreferenceViewModel()
        await model.toggleSubscription()

        assert(model.isLoading == false)
        assert(model.isUnsubscribed == false)
    }
}
