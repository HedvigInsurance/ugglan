import AppStateContainer
import Foundation
import Testing
import hCore

@testable import Profile

extension ProfileDependencySuite {
    @MainActor
    final class MemberSubscriptionPreferenceViewModelTests {
        private weak var sut: MockProfileService?

        init() {
            UserDefaults.standard.removeObject(forKey: MemberSubscriptionPreferenceViewModel.userDefaultsKey)
            globalAppStateContainer.clearPersistence()
        }

        // Test bodies are scoped so their locals are released before this check runs.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ProfileClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func toggleSubscriptionSuccess() async {
            do {
                let mockService = MockData.createMockProfileService(
                    subscriptionPreferenceUpdate: { _ in }
                )

                sut = mockService

                let model = MemberSubscriptionPreferenceViewModel()
                let currentValue = model.isUnsubscribed
                await model.toggleSubscription()
                #expect(model.isLoading == false)
                #expect(model.isUnsubscribed == !currentValue)
            }

            await expectServiceReleased()
        }

        @Test
        func toggleSubscriptionFailure() async {
            do {
                let mockService = MockData.createMockProfileService(
                    subscriptionPreferenceUpdate: { _ in
                        throw ProfileError.error(message: "error")
                    }
                )

                sut = mockService

                let model = MemberSubscriptionPreferenceViewModel()
                await model.toggleSubscription()

                #expect(model.isLoading == false)
                #expect(model.isUnsubscribed == false)
            }

            await expectServiceReleased()
        }
    }
}
