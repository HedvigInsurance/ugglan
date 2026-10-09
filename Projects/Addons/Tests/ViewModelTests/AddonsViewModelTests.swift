import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsViewModelTests: XCTestCase {
    weak var sut: MockAddonsService?
    weak var vm: ChangeAddonViewModel?
    weak var eventTracker: MockEventTrackingClient?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        Dependencies.shared.remove(for: EventTrackingClient.self)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
        XCTAssertNil(eventTracker)
    }

    // MARK: - Selectable (travel) tests

    func testSelectableAddonSelection() async throws {
        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        assert(model.offer == testTravelOfferNoActive)
        assert(model.selectedAddons == [travelQuote45Days])

        // Select second quote — should replace, not add
        model.selectAddon(addon: travelQuote60Days)
        assert(model.selectedAddons == [travelQuote60Days])

        // Re-select first — still replaces
        model.selectAddon(addon: travelQuote45Days)
        assert(model.selectedAddons == [travelQuote45Days])
    }

    func testSubmitAddonsSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
        let mockEventTracker = MockData.createMockEventTrackingClient()

        sut = mockService
        eventTracker = mockEventTracker

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        await model.submitAddons()

        assert(model.submittingState == .success)

        XCTAssertEqual(mockEventTracker.trackedEvents.count, 1)
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

    func testSubmitSelectableUpgradeFromContractDetailTracksUpgrade() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
        let mockEventTracker = MockData.createMockEventTrackingClient()

        sut = mockService
        eventTracker = mockEventTracker

        let model = ChangeAddonViewModel(offer: testTravelOffer45Days.with(source: .contractDetail))

        vm = model

        await model.submitAddons()

        assert(model.submittingState == .success)

        XCTAssertEqual(mockEventTracker.trackedEvents.count, 1)
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

    func testSubmitToggleableAddonsNextToActiveOneTracksNewPurchasePerAddon() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })
        let mockEventTracker = MockData.createMockEventTrackingClient()

        sut = mockService
        eventTracker = mockEventTracker

        let model = ChangeAddonViewModel(offer: testCarAddonRisk.with(source: .homeCrossSellSheet))

        vm = model

        model.selectAddon(addon: carQuoteHyrbil)
        model.selectAddon(addon: carQuoteDrulle)
        await model.submitAddons()

        assert(model.submittingState == .success)

        XCTAssertEqual(mockEventTracker.trackedEvents.count, 2)
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

    func testSubmitAddonsFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            addonsSubmit: { _, _ in throw AddonsError.submitError }
        )
        let mockEventTracker = MockData.createMockEventTrackingClient()

        sut = mockService
        eventTracker = mockEventTracker

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        await model.submitAddons()

        assert(model.submittingState == .error(errorMessage: AddonsError.submitError.localizedDescription))
        XCTAssertTrue(mockEventTracker.trackedEvents.isEmpty)
    }

    // MARK: - Addon offer cost tests

    func testGetAddonOfferCostSuccess() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOfferCost: { _, _ in testAddonOfferCost }
        )

        sut = mockService

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        model.selectAddon(addon: travelQuote45Days)
        await model.getAddonOfferCost()

        assert(model.fetchingCostState == .success)
        assert(model.addonOfferCost == testAddonOfferCost)
    }

    func testGetAddonOfferCostFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOfferCost: { _, _ in throw AddonsError.somethingWentWrong }
        )

        sut = mockService

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        model.selectAddon(addon: travelQuote45Days)
        await model.getAddonOfferCost()

        assert(model.addonOfferCost == nil)
        assert(model.fetchingCostState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription))
    }

    // MARK: - Toggleable (car) tests

    func testToggleableAddonSelection() async throws {
        let model = ChangeAddonViewModel(offer: testCarOfferNoActive)

        vm = model

        assert(model.offer == testCarOfferNoActive)
        assert(model.selectedAddons.isEmpty)

        // Toggle first addon on
        model.selectAddon(addon: carQuoteSjalvrisk)
        assert(model.selectedAddons == [carQuoteSjalvrisk])

        // Toggle second addon on
        model.selectAddon(addon: carQuoteHyrbil)
        assert(model.selectedAddons == [carQuoteSjalvrisk, carQuoteHyrbil])

        // Toggle first addon off
        model.selectAddon(addon: carQuoteSjalvrisk)
        assert(model.selectedAddons == [carQuoteHyrbil])
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
        line: UInt = #line
    ) {
        XCTAssertEqual(event.name, "addon_purchased", line: line)
        XCTAssertEqual(event.parameters["user_flow"] as? String, userFlow, line: line)
        XCTAssertEqual(event.parameters["addon_type"] as? String, addonType, line: line)
        XCTAssertEqual(event.parameters["contract_id"] as? String, contractId, line: line)
        XCTAssertEqual(event.parameters["price"] as? Double, price, line: line)
        XCTAssertEqual(event.parameters["currency"] as? String, currency, line: line)
        XCTAssertEqual(event.parameters["quote_id"] as? String, quoteId, line: line)
        XCTAssertEqual(event.parameters["purchase_type"] as? String, purchaseType, line: line)
    }
}
