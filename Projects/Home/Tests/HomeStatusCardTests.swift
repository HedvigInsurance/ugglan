import AppStateContainer
import XCTest
import hCore

@testable import Home

@MainActor
final class HomeStatusCardTests: XCTestCase {
    weak var sut: HomeBottomScrollViewModel?

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

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        MockData.createMockHomeService()
        sut = nil
    }

    override func tearDown() async throws {
        // The view model reads the singleton HomeStore, so leave the next test a member state it
        // did not have to guess at.
        let store: HomeStore = globalAppStateContainer.get()
        store.setMemberContractState(.loading, contracts: [])
        store.setFutureStatus(.none)
        Dependencies.shared.remove(for: HomeClient.self)

        await waitUntil(description: "View model deinit") { self.sut == nil }

        XCTAssertNil(sut)
        try await super.tearDown()
    }

    /// One view model for the whole table, and every row is preceded by the opposite state, so each
    /// row observes a real transition rather than passing on the previous row's card.
    func testMemberStateAndFutureStatusShowAtMostOneStatusCard() async {
        let store: HomeStore = globalAppStateContainer.get()
        let vm = HomeBottomScrollViewModel()
        sut = vm

        for statusCase in Self.statusCases {
            let previousState = statusCase.card == nil ? Self.cardShowingState : Self.cardFreeState
            await apply(previousState, to: store, assertingOn: vm)
            await apply(statusCase, to: store, assertingOn: vm)
        }
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
        XCTAssertEqual(statusCards(of: vm), expectedCards, description)
        XCTAssertEqual(statusMessages(of: vm), expectedMessages, description)
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
