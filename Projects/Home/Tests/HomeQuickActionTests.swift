import AppStateContainer
import Payment
import SubmitClaimChat
import Testing
import hCore

@testable import Home

extension HomeDependencySuite {
    @MainActor
    final class HomeQuickActionTests {
        private weak var sut: HomeStore?

        init() {
            resetContainer()
            Dependencies.shared.add(module: Module { () -> DateService in DateService() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        // Test bodies are scoped in a do block so their locals are released before this check.
        private func resetContainerAndExpectStoreReleased() async {
            Dependencies.shared.remove(for: HomeClient.self)
            Dependencies.shared.remove(for: hPaymentClient.self)
            resetContainer()
            try? await Task.sleep(for: .seconds(0.0000001))

            #expect(sut == nil, "the home store must not outlive the test that created it")
        }

        @Test
        func homeQuickActionsOrder() async {
            do {
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

                #expect(
                    store.homeQuickActions == [
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

            await resetContainerAndExpectStoreReleased()
        }

        @Test
        func homeQuickActionsShowUpcomingPaymentOnlyOnceItIsLoaded() async {
            do {
                let paymentClient = MockPaymentClient(upcomingPayment: nil)
                let store = await makeStore(quickActions: [.changeAddress], paymentClient: paymentClient)

                #expect(store.homeQuickActions == [.changeAddress, .inviteFriend])

                let upcoming = PaymentData.fixture
                paymentClient.upcomingPayment = upcoming
                let paymentStore: PaymentStore = globalAppStateContainer.get()
                await paymentStore.load(forceUpdate: true)

                #expect(store.homeQuickActions == [.changeAddress, .inviteFriend, .upcomingPayment])
            }

            await resetContainerAndExpectStoreReleased()
        }

        @Test
        func homeQuickActionsOmitUpgradeCoverageWithoutNestedFlag() async {
            do {
                let editActions = EditInsuranceActionsWrapper(quickActions: [.editCoInsured, .cancellation])
                let upcoming = PaymentData.fixture
                let store = await makeStore(
                    quickActions: [.editInsurance(actions: editActions)],
                    paymentClient: MockPaymentClient(upcomingPayment: upcoming)
                )

                #expect(store.homeQuickActions == [.editInsurance(editActions), .inviteFriend, .upcomingPayment])
            }

            await resetContainerAndExpectStoreReleased()
        }

        @Test
        func upcomingPaymentTilePresentsFreshlyFetchedPayment() async {
            do {
                let paymentClient = MockPaymentClient(upcomingPayment: nil)
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentClient })
                let paymentStore: PaymentStore = globalAppStateContainer.get()
                await paymentStore.load()

                let fresh = PaymentData.fixture
                paymentClient.upcomingPayment = fresh
                let vm = HomeNavigationViewModel()
                await vm.presentUpcomingPayment()

                #expect(vm.isUpcomingPaymentPresented == fresh)
            }

            await resetContainerAndExpectStoreReleased()
        }

        @Test
        func upcomingPaymentTileDoesNotPresentWhenFetchFails() async {
            do {
                let paymentClient = MockPaymentClient(upcomingPayment: nil)
                paymentClient.error = PaymentError.missingDataError(message: "failed")
                Dependencies.shared.add(module: Module { () -> hPaymentClient in paymentClient })
                let paymentStore: PaymentStore = globalAppStateContainer.get()

                let vm = HomeNavigationViewModel()
                await vm.presentUpcomingPayment()

                #expect(paymentStore.loadPaymentDataError != nil)
                #expect(vm.isUpcomingPaymentPresented == nil)
            }

            await resetContainerAndExpectStoreReleased()
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
        var error: Error?

        init(upcomingPayment: PaymentData?) {
            self.upcomingPayment = upcomingPayment
        }

        func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
            if let error { throw error }
            return (upcomingPayment, [])
        }

        func getPaymentStatusData() async throws -> PaymentStatusData {
            throw PaymentError.missingDataError(message: "unused")
        }

        func getPaymentNoticeData() async throws -> PaymentNoticeData {
            .init(memberId: "memberId", preChargeNoticeId: nil, retryChargeNoticeId: nil)
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

        func getPaymentSetupStatus(orderId _: String) async throws -> PaymentSetupResult.PaymentSetupStatus {
            .unknown
        }

        func chargeOutstandingPayment() async throws {}

        func setDefaultPaymentMethod(_: PaymentMethod) async throws {}

        func setDefaultPayoutMethod(_: PaymentMethod) async throws {}

        func removePaymentMethod(_: PaymentProvider) async throws {}
    }
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
