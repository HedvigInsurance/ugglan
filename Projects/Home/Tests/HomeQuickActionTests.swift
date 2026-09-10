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

    func testHomeQuickActionsOrder() async {
        let editActions = EditInsuranceActionsWrapper(
            quickActions: [.editCoInsured, .upgradeCoverage, .cancellation]
        )
        // Deflection.init mints a fresh id, so both sides must share one instance.
        let deflection = Deflection.fixture
        let upcoming = PaymentData.fixture
        let store = await makeStore(
            quickActions: [
                .travelInsurance,
                .sickAbroad(deflection: deflection),
                .editInsurance(actions: editActions),
                .connectPayments,
                .changeAddress,
                .firstVet(partners: [.init(id: "vet", description: nil, url: nil, title: nil)]),
            ],
            paymentClient: MockPaymentClient(upcomingPayment: upcoming)
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
                .upcomingPayment(upcoming),
            ]
        )
    }

    func testHomeQuickActionsShowUpcomingPaymentOnlyOnceItIsLoaded() async {
        let paymentClient = MockPaymentClient(upcomingPayment: nil)
        let store = await makeStore(quickActions: [.changeAddress], paymentClient: paymentClient)

        XCTAssertEqual(store.homeQuickActions, [.changeAddress, .inviteFriend])

        let upcoming = PaymentData.fixture
        paymentClient.upcomingPayment = upcoming
        let paymentStore: PaymentStore = globalAppStateContainer.get()
        await paymentStore.load(forceUpdate: true)

        XCTAssertEqual(store.homeQuickActions, [.changeAddress, .inviteFriend, .upcomingPayment(upcoming)])
    }

    func testHomeQuickActionsOmitUpgradeCoverageWithoutNestedFlag() async {
        let editActions = EditInsuranceActionsWrapper(quickActions: [.editCoInsured, .cancellation])
        let upcoming = PaymentData.fixture
        let store = await makeStore(
            quickActions: [.editInsurance(actions: editActions)],
            paymentClient: MockPaymentClient(upcomingPayment: upcoming)
        )

        XCTAssertEqual(
            store.homeQuickActions,
            [.editInsurance(editActions), .inviteFriend, .upcomingPayment(upcoming)]
        )
    }

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

    // reset before clearing: it cancels the debounced snapshot write that would otherwise land after the wipe
    private func resetContainer() {
        globalAppStateContainer.reset()
        globalAppStateContainer.clearPersistence()
    }
}

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
