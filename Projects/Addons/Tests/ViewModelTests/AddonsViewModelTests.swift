import TestDependencies
import Testing
import hCore

@testable import Addons

extension AddonsDependencySuite {
    @MainActor
    final class AddonsViewModelTests {
        private weak var sut: MockAddonsService?
        private weak var vm: ChangeAddonViewModel?
        private weak var eventTracker: MockEventTrackingClient?

        // Bodies are scoped in do/recordingErrors so locals are released and throws still reach this check.
        private func expectEverythingReleased() {
            Dependencies.shared.remove(for: AddonsClient.self)
            Dependencies.shared.remove(for: EventTrackingClient.self)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
            #expect(vm == nil, "the view model must not outlive the test that created it")
            #expect(eventTracker == nil, "the event tracker must not outlive its dependency registration")
        }

        // MARK: - Selectable (travel) tests

        @Test
        func selectableAddonSelection() async {
            do {
                let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

                vm = model

                #expect(model.offer == testTravelOfferNoActive)
                #expect(model.selectedAddons == [travelQuote45Days])

                // Select second quote — should replace, not add
                model.selectAddon(addon: travelQuote60Days)
                #expect(model.selectedAddons == [travelQuote60Days])

                // Re-select first — still replaces
                model.selectAddon(addon: travelQuote45Days)
                #expect(model.selectedAddons == [travelQuote45Days])
            }

            expectEverythingReleased()
        }

        @Test
        func submitAddonsSuccess() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
                let mockEventTracker = MockData.createMockEventTrackingClient()

                sut = mockService
                eventTracker = mockEventTracker

                let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

                vm = model

                await model.submitAddons()

                #expect(model.submittingState == .success)

                try #require(mockEventTracker.trackedEvents.count == 1)
                assertAddonPurchased(
                    mockEventTracker.trackedEvents[0],
                    userFlow: "insurance_screen",
                    addonType: "travel",
                    contractId: "travelContractId",
                    price: 59,
                    currency: "SEK",
                    quoteId: "quoteId1",
                    purchaseType: "new"
                )
            }

            expectEverythingReleased()
        }

        @Test
        func submitSelectableUpgradeFromContractDetailTracksUpgrade() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
                let mockEventTracker = MockData.createMockEventTrackingClient()

                sut = mockService
                eventTracker = mockEventTracker

                let model = ChangeAddonViewModel(offer: testTravelOffer45Days.with(source: .contractDetail))

                vm = model

                await model.submitAddons()

                #expect(model.submittingState == .success)

                try #require(mockEventTracker.trackedEvents.count == 1)
                assertAddonPurchased(
                    mockEventTracker.trackedEvents[0],
                    userFlow: "insurance_card",
                    addonType: "travel",
                    contractId: "travelContractId",
                    price: 67,
                    currency: "SEK",
                    quoteId: "quoteId2",
                    purchaseType: "upgrade"
                )
            }

            expectEverythingReleased()
        }

        @Test
        func submitToggleableAddonsNextToActiveOneTracksNewPurchasePerAddon() async {
            await recordingErrors {
                let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
                let mockEventTracker = MockData.createMockEventTrackingClient()

                sut = mockService
                eventTracker = mockEventTracker

                let model = ChangeAddonViewModel(offer: testCarAddonRisk.with(source: .homeCrossSellSheet))

                vm = model

                model.selectAddon(addon: carQuoteHyrbil)
                model.selectAddon(addon: carQuoteDrulle)
                await model.submitAddons()

                #expect(model.submittingState == .success)

                try #require(mockEventTracker.trackedEvents.count == 2)
                assertAddonPurchased(
                    mockEventTracker.trackedEvents[0],
                    userFlow: "home",
                    addonType: "car_addon",
                    contractId: "carContractId",
                    price: 33,
                    currency: "SEK",
                    quoteId: "carQuoteId2",
                    purchaseType: "new"
                )
                assertAddonPurchased(
                    mockEventTracker.trackedEvents[1],
                    userFlow: "home",
                    addonType: "car_addon",
                    contractId: "carContractId",
                    price: 25,
                    currency: "SEK",
                    quoteId: "carQuoteId2",
                    purchaseType: "new"
                )
            }

            expectEverythingReleased()
        }

        @Test
        func submitAddonsFailure() async {
            do {
                let mockService = MockData.createMockAddonsService(
                    addonsSubmit: { _, _ in throw AddonsError.submitError }
                )
                let mockEventTracker = MockData.createMockEventTrackingClient()

                sut = mockService
                eventTracker = mockEventTracker

                let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

                vm = model

                await model.submitAddons()

                #expect(model.submittingState == .error(errorMessage: AddonsError.submitError.localizedDescription))
                #expect(mockEventTracker.trackedEvents.isEmpty)
            }

            expectEverythingReleased()
        }

        // MARK: - Addon offer cost tests

        @Test
        func getAddonOfferCostSuccess() async {
            do {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonOfferCost: { _, _ in testAddonOfferCost }
                )

                sut = mockService

                let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

                vm = model

                model.selectAddon(addon: travelQuote45Days)
                await model.getAddonOfferCost()

                #expect(model.fetchingCostState == .success)
                #expect(model.addonOfferCost == testAddonOfferCost)
            }

            expectEverythingReleased()
        }

        @Test
        func getAddonOfferCostFailure() async {
            do {
                let mockService = MockData.createMockAddonsService(
                    fetchAddonOfferCost: { _, _ in throw AddonsError.somethingWentWrong }
                )

                sut = mockService

                let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

                vm = model

                model.selectAddon(addon: travelQuote45Days)
                await model.getAddonOfferCost()

                #expect(model.addonOfferCost == nil)
                #expect(
                    model.fetchingCostState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription)
                )
            }

            expectEverythingReleased()
        }

        // MARK: - Toggleable (car) tests

        @Test
        func toggleableAddonSelection() async {
            do {
                let model = ChangeAddonViewModel(offer: testCarOfferNoActive)

                vm = model

                #expect(model.offer == testCarOfferNoActive)
                #expect(model.selectedAddons.isEmpty)

                model.selectAddon(addon: carQuoteSjalvrisk)
                #expect(model.selectedAddons == [carQuoteSjalvrisk])

                model.selectAddon(addon: carQuoteHyrbil)
                #expect(model.selectedAddons == [carQuoteSjalvrisk, carQuoteHyrbil])

                model.selectAddon(addon: carQuoteSjalvrisk)
                #expect(model.selectedAddons == [carQuoteHyrbil])
            }

            expectEverythingReleased()
        }

        private func assertAddonPurchased(
            _ event: MockEventTrackingClient.TrackedEvent,
            userFlow: String,
            addonType: String,
            contractId: String,
            price: Double,
            currency: String,
            quoteId: String,
            purchaseType: String,
            sourceLocation: SourceLocation = #_sourceLocation
        ) {
            #expect(event.name == "addon_purchased", sourceLocation: sourceLocation)
            #expect(event.parameters["user_flow"] as? String == userFlow, sourceLocation: sourceLocation)
            #expect(event.parameters["addon_type"] as? String == addonType, sourceLocation: sourceLocation)
            #expect(event.parameters["contract_id"] as? String == contractId, sourceLocation: sourceLocation)
            #expect(event.parameters["price"] as? Double == price, sourceLocation: sourceLocation)
            #expect(event.parameters["currency"] as? String == currency, sourceLocation: sourceLocation)
            #expect(event.parameters["quote_id"] as? String == quoteId, sourceLocation: sourceLocation)
            #expect(event.parameters["purchase_type"] as? String == purchaseType, sourceLocation: sourceLocation)
        }
    }
}
