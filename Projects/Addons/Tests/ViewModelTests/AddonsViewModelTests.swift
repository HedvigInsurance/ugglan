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

    func testFetchSelectableAddonOfferSuccess() async throws {
        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in testTravelOfferNoActive })

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)

        assert(model.addonOffer == testTravelOfferNoActive)
        assert(model.fetchAddonsViewState == .success)
        assert(model.selectedAddons == [travelQuote45Days])

        // Select second quote — should replace, not add
        model.selectAddon(addon: travelQuote60Days)
        assert(model.selectedAddons == [travelQuote60Days])
        assert(model.selectedAddons.count == 1)

        // Re-select first — still replaces
        model.selectAddon(addon: travelQuote45Days)
        assert(model.selectedAddons == [travelQuote45Days])
        assert(model.selectedAddons.count == 1)
    }

    func testFetchAddonOfferFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in throw AddonsError.somethingWentWrong })

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)

        assert(model.addonOffer == nil)
        assert(model.selectedAddons.isEmpty)

        assert(model.fetchAddonsViewState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription))
    }

    func testSubmitAddonsSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in })

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)

        await model.submitAddons()

        assert(model.submittingAddonsViewState == .success)
    }

    func testSubmitAddonsFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in throw AddonsError.submitError },
            addonsSubmit: { _, _ in throw AddonsError.submitError }
        )

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)
        await model.submitAddons()

        assert(model.submittingAddonsViewState == .error(errorMessage: AddonsError.submitError.localizedDescription))
    }

    // MARK: - Addon offer cost tests

    func testGetAddonOfferCostSuccess() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in testTravelOfferNoActive },
            fetchAddonOfferCost: { _, _ in testAddonOfferCost }
        )

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)

        await model.getAddonOfferCost()

        assert(model.fetchingCostState == .success)
        assert(model.addonOfferCost == testAddonOfferCost)
    }

    func testGetAddonOfferCostFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in testTravelOfferNoActive },
            fetchAddonOfferCost: { _, _ in throw AddonsError.somethingWentWrong }
        )

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)

        await model.getAddonOfferCost()

        assert(model.addonOfferCost == nil)

        assert(model.fetchingCostState == .error(errorMessage: AddonsError.somethingWentWrong.localizedDescription))
    }

    // MARK: - Toggleable (car) tests

    func testFetchToggleableAddonOfferSuccess() async throws {
        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in testCarOfferNoActive })

        sut = mockService

        let model = ChangeAddonViewModel(config: testAddonConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)
        assert(model.addonOffer == testCarOfferNoActive)
        assert(model.fetchAddonsViewState == .success)
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
