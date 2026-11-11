import AppStateContainer
import Foundation
import TestDependencies
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class HomeStoreFetchHomeDataTests {
        private weak var sut: MockHomeService?
        private weak var store: HomeStore?

        init() {
            globalAppStateContainer.clearPersistence()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func expectStoreAndServiceReleased() async {
            Dependencies.shared.remove(for: HomeClient.self)
            await delay(0.0000001)

            #expect(store == nil, "the home store must not outlive the test that created it")
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        @Test
        func fetchHomeDataAppliesEveryPartSuccess() async {
            do {
                let mockService = MockData.createMockHomeService(
                    fetchImportantMessages: { [.init(id: "message-1", message: "Important", linkInfo: nil)] },
                    fetchMemberState: { Self.makeMemberState(firstName: "Combined") },
                    fetchQuickActions: { [.editCoInsured] }
                )
                sut = mockService

                let store = HomeStore()
                self.store = store
                await store.fetchHomeData()

                #expect(store.memberInfo?.firstName == "Combined")
                #expect(store.memberContractState == .active)
                #expect(store.importantMessages.map(\.id) == ["message-1"])
                #expect(store.quickActions == [.editCoInsured])
                #expect(store.isFetchingQuickActions == false)
                #expect(store.fetchMemberStateError == nil)
                #expect(store.fetchQuickActionsError == nil)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func fetchHomeDataFailureSetsMemberStateAndQuickActionsErrors() async {
            do {
                let mockService = MockData.createMockHomeService(
                    fetchQuickActions: { throw NetworkError.badRequest(message: nil) }
                )
                sut = mockService

                let store = HomeStore()
                self.store = store
                await store.fetchHomeData()

                // One request backs every part, so a failure leaves all of them unloaded.
                #expect(store.fetchMemberStateError != nil)
                #expect(store.fetchQuickActionsError != nil)
                #expect(store.memberInfo == nil)
                #expect(store.quickActions.isEmpty)
                #expect(store.isFetchingQuickActions == false)
            }

            await expectStoreAndServiceReleased()
        }

        @Test
        func fetchHomeDataSuccessClearsEarlierErrors() async {
            do {
                let mockService = MockData.createMockHomeService(
                    fetchMemberState: { throw NetworkError.badRequest(message: nil) }
                )
                sut = mockService

                let store = HomeStore()
                self.store = store
                await store.fetchHomeData()
                #expect(store.fetchMemberStateError != nil)
                #expect(store.fetchQuickActionsError != nil)

                mockService.fetchMemberState = { Self.makeMemberState() }
                await store.fetchHomeData()

                #expect(store.fetchMemberStateError == nil)
                #expect(store.fetchQuickActionsError == nil)
                #expect(store.memberInfo?.firstName == "Test")
            }

            await expectStoreAndServiceReleased()
        }

        private static func makeMemberState(firstName: String = "Test") -> MemberState {
            .init(
                memberInfo: .init(id: "id", firstName: firstName, isContactInfoUpdateNeeded: false),
                contracts: [],
                contractState: .active,
                futureState: .none
            )
        }
    }
}
