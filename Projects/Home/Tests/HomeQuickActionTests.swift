import AppStateContainer
import Payment
import SubmitClaimChat
import XCTest
import hCore

@testable import Home

@MainActor
final class HomeQuickActionTests: XCTestCase {
    weak var sut: HomeStore?

    override func setUp() async throws {
        try await super.setUp()
        resetContainer()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: HomeClient.self)
        Dependencies.shared.remove(for: hPaymentClient.self)
        resetContainer()
        try await Task.sleep(seconds: 0.0000001)

        XCTAssertNil(sut)
    }

    // reset first: it cancels the 250 ms debounced snapshot write that would otherwise land after the wipe
    private func resetContainer() {
        globalAppStateContainer.reset()
        globalAppStateContainer.clearPersistence()
    }

    func testHomeQuickActionsFollowFigmaOrderWithUpcomingPayment() async {
        let editActions = EditInsuranceActionsWrapper(
            quickActions: [.editCoInsured, .upgradeCoverage, .cancellation]
        )
        // Deflection.init mints a fresh id, so the same instance has to appear on both sides.
        let deflection = Deflection.fixture
        // Deliberately not in tile order -- the row's order comes from the store's literal,
        // never from the order the backend happened to send.
        let store = await makeStore(
            quickActions: [
                .travelInsurance,
                .sickAbroad(deflection: deflection),
                .editInsurance(actions: editActions),
                .connectPayments,
                .changeAddress,
                .firstVet(partners: [.init(id: "vet", description: nil, url: nil, title: nil)]),
            ],
            paymentClient: MockPaymentClient(upcomingPayment: .fixture)
        )

        XCTAssertEqual(
            store.homeQuickActions,
            [
                .editInsurance(editActions),
                .changeAddress,
                .travelCertificate,
                .sickAbroad(deflection),
                .upgradeCoverage,
                .inviteFriend,
                .upcomingPayment,
            ]
        )
    }

    func testHomeQuickActionsShowUpcomingPaymentOnlyOnceItIsLoaded() async {
        let paymentClient = MockPaymentClient(upcomingPayment: nil)
        let store = await makeStore(quickActions: [.changeAddress], paymentClient: paymentClient)

        XCTAssertEqual(store.homeQuickActions, [.changeAddress, .inviteFriend])

        paymentClient.upcomingPayment = .fixture
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        await paymentStore.load(forceUpdate: true)

        XCTAssertEqual(store.homeQuickActions, [.changeAddress, .inviteFriend, .upcomingPayment])
    }

    func testHomeQuickActionsHideUpcomingPaymentWhenNothingIsDue() async {
        let store = await makeStore(
            quickActions: [.travelInsurance],
            paymentClient: MockPaymentClient(upcomingPayment: nil)
        )

        XCTAssertEqual(store.homeQuickActions, [.travelCertificate, .inviteFriend])
    }

    func testHomeQuickActionsOmitUpgradeCoverageWithoutNestedFlag() async {
        let editActions = EditInsuranceActionsWrapper(quickActions: [.editCoInsured, .cancellation])
        let store = await makeStore(
            quickActions: [.editInsurance(actions: editActions)],
            paymentClient: MockPaymentClient(upcomingPayment: .fixture)
        )

        XCTAssertEqual(store.homeQuickActions, [.editInsurance(editActions), .inviteFriend, .upcomingPayment])
    }

    func testHomeQuickActionsIgnoreTopLevelUpgradeCoverageAndNonTileActions() async {
        // .upgradeCoverage only ever arrives nested inside .editInsurance; a top-level one
        // must not produce a tile, or it would appear for members the backend never
        // enabled change-tier for.
        let store = await makeStore(
            quickActions: [
                .connectPayments,
                .upgradeCoverage,
                .editCoInsured,
                .editCoOwners,
                .removeAddons,
                .cancellation,
                .firstVet(partners: []),
            ],
            paymentClient: MockPaymentClient(upcomingPayment: .fixture)
        )

        XCTAssertEqual(store.homeQuickActions, [.inviteFriend, .upcomingPayment])
    }

    /// Registers both service mocks, builds the store and drives the two fetches the
    /// pipeline combines -- the same two `HomeVM.fetchHomeState()` fires on appear.
    private func makeStore(quickActions: [QuickAction], paymentClient: MockPaymentClient) async -> HomeStore {
        MockData.createMockHomeService(fetchQuickActions: { quickActions })
        Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentClient })
        let store = HomeStore()
        sut = store

        await store.fetchQuickActions()
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        await paymentStore.load()
        return store
    }
}

/// Boundary mock: only the call the Home pipeline can trigger returns data.
private final class MockPaymentClient: hPaymentClient, @unchecked Sendable {
    var upcomingPayment: PaymentData?

    init(upcomingPayment: PaymentData?) {
        self.upcomingPayment = upcomingPayment
    }

    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
        (upcomingPayment, [])
    }

    func getPaymentStatusData() async throws -> PaymentStatusData {
        throw PaymentError.missingDataError(message: "unused")
    }

    func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        []
    }

    func getMissedPaymentData() async throws -> MissedPaymentData? {
        nil
    }

    func setupPaymentMethod(_ type: PaymentMethodSetupType) async throws -> PaymentSetupResult {
        throw PaymentError.missingDataError(message: "unused")
    }

    func chargeOutstandingPayment() async throws {}
}

extension PaymentData {
    fileprivate static var fixture: PaymentData {
        .init(
            id: "upcoming",
            payment: .init(
                gross: .init(amount: "230", currency: "SEK"),
                net: .init(amount: "230", currency: "SEK"),
                carriedAdjustment: nil,
                settlementAdjustment: nil,
                date: .init()
            ),
            status: .upcoming,
            contracts: [],
            referralDiscount: nil,
            amountPerReferral: .init(amount: "0", currency: "SEK"),
            payinMethod: nil,
            addedToThePayment: nil
        )
    }
}

extension SubmitClaimChat.Deflection {
    fileprivate static var fixture: SubmitClaimChat.Deflection {
        .init(
            title: nil,
            content: .init(title: "", description: ""),
            partners: [],
            infoText: nil,
            warningText: nil,
            questions: [],
            linkOnlyPartners: [],
            buttonTitle: ""
        )
    }
}
