import AppStateContainer
import TestDependencies
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class HomeStatusCardTests {
        private weak var sut: HomeBottomScrollViewModel?

        private typealias StatusCase = (
            state: MemberContractState,
            futureStatus: FutureStatus,
            card: InfoCardType?,
            message: String?
        )

        private static let inceptionDate = "2026-09-01"

        private static var statusCases: [StatusCase] {
            [
                (.terminated, .none, .terminated, L10n.HomeTab.terminatedBody),
                (.terminated, .pendingSwitchable, .terminated, L10n.HomeTab.terminatedBody),
                (.terminated, .pendingNonswitchable, .terminated, L10n.HomeTab.terminatedBody),
                (.terminated, .activeInFuture(inceptionDate: inceptionDate), .terminated, L10n.HomeTab.terminatedBody),
                (
                    .future, .activeInFuture(inceptionDate: inceptionDate),
                    .activeInFuture(inceptionDate: inceptionDate), L10n.HomeTab.activeInFutureInfo(inceptionDate)
                ),
                (.future, .pendingSwitchable, .pendingSwitchable, L10n.HomeTab.pendingSwitchableInfo),
                (.future, .pendingNonswitchable, .pendingNonswitchable, L10n.HomeTab.pendingNonswitchableInfo),
                (.future, .none, nil, nil),
                (.active, .pendingSwitchable, nil, nil),
                (.active, .activeInFuture(inceptionDate: inceptionDate), nil, nil),
                (.loading, .none, nil, nil),
                (.loading, .pendingNonswitchable, nil, nil),
            ]
        }

        private static var cardFreeState: StatusCase {
            (.active, .none, nil, nil)
        }

        private static var cardShowingState: StatusCase {
            (.future, .pendingSwitchable, .pendingSwitchable, L10n.HomeTab.pendingSwitchableInfo)
        }

        init() {
            globalAppStateContainer.clearPersistence()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
            MockData.createMockHomeService()
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func resetStoreAndExpectViewModelReleased() async {
            // The view model reads the singleton HomeStore, so reset its member state for the next test.
            let store: HomeStore = globalAppStateContainer.get()
            store.setMemberContractState(.loading, contracts: [])
            store.setFutureStatus(.none)
            Dependencies.shared.remove(for: HomeClient.self)

            await waitUntil(description: "View model deinit") { self.sut == nil }

            #expect(sut == nil, "the bottom scroll view model must not outlive the test that created it")
        }

        /// Each row is preceded by the opposite state, so it observes a real transition on the shared view model.
        @Test
        func memberStateAndFutureStatusShowAtMostOneStatusCard() async {
            do {
                let store: HomeStore = globalAppStateContainer.get()
                let vm = HomeBottomScrollViewModel()
                sut = vm

                for statusCase in Self.statusCases {
                    let previousState = statusCase.card == nil ? Self.cardShowingState : Self.cardFreeState
                    await apply(previousState, to: store, assertingOn: vm)
                    await apply(statusCase, to: store, assertingOn: vm)
                }
            }

            await resetStoreAndExpectViewModelReleased()
        }

        private func apply(
            _ statusCase: StatusCase,
            to store: HomeStore,
            assertingOn vm: HomeBottomScrollViewModel
        ) async {
            let expectedCards = [statusCase.card].compactMap { $0 }
            let expectedMessages = [statusCase.message].compactMap { $0 }
            let description = "\(statusCase.state) + \(statusCase.futureStatus) shows \(expectedMessages)"

            store.setMemberContractState(statusCase.state, contracts: [])
            store.setFutureStatus(statusCase.futureStatus)

            await waitUntil(description: description) { self.statusCards(of: vm) == expectedCards }
            #expect(statusCards(of: vm) == expectedCards, "\(description)")
            #expect(statusMessages(of: vm) == expectedMessages, "\(description)")
        }

        private func statusCards(of vm: HomeBottomScrollViewModel) -> [InfoCardType] {
            vm.items
                .map(\.id)
                .filter(\.isStatusMessage)
        }

        private func statusMessages(of vm: HomeBottomScrollViewModel) -> [String] {
            statusCards(of: vm)
                .compactMap(\.statusMessage)
        }
    }
}
