@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsViewModelTests: XCTestCase {
    weak var sut: MockAddonsService?
    weak var vm: ChangeAddonViewModel?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
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

        sut = mockService

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        await model.submitAddons()

        assert(model.submittingAddonsViewState == .success)
    }

    func testSubmitAddonsFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            addonsSubmit: { _, _ in throw AddonsError.submitError }
        )

        sut = mockService

        let model = ChangeAddonViewModel(offer: testTravelOfferNoActive)

        vm = model

        await model.submitAddons()

        assert(model.submittingAddonsViewState == .error(errorMessage: AddonsError.submitError.localizedDescription))
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
}
