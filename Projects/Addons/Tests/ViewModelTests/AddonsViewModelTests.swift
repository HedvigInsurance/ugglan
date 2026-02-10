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
        let fixedDate = Date()

        let travelQuote45 = AddonOfferQuote(
            id: "addon45",
            displayTitle: "45 days",
            displayDescription: "Coverage for trips up to 45 days",
            displayItems: [.init(displayTitle: "Coverage", displayValue: "45 days")],
            cost: .init(premium: .init(gross: .sek(49), net: .sek(49)), discounts: []),
            addonVariant: .init(
                displayName: "Travel Insurance Plus 45",
                documents: [],
                perils: [],
                product: "travel",
                termsVersion: "1.0"
            ),
            subType: "45 days"
        )
        let travelQuote60 = AddonOfferQuote(
            id: "addon60",
            displayTitle: "60 days",
            displayDescription: "Coverage for trips up to 60 days",
            displayItems: [.init(displayTitle: "Coverage", displayValue: "60 days")],
            cost: .init(premium: .init(gross: .sek(79), net: .sek(79)), discounts: []),
            addonVariant: .init(
                displayName: "Travel Insurance Plus 60",
                documents: [],
                perils: [],
                product: "travel",
                termsVersion: "1.0"
            ),
            subType: "60 days"
        )

        let travelOffer = AddonOffer(
            pageTitle: "Extend your coverage",
            pageDescription: "Get extra coverage when you travel abroad",
            quote: .init(
                quoteId: "quoteId1",
                displayTitle: "Travel Insurance Plus",
                displayDescription: "Extra coverage for trips abroad",
                activationDate: fixedDate,
                addonOffer: .selectable(
                    .init(
                        fieldTitle: "Maximum travel days",
                        selectionTitle: "Choose your coverage",
                        selectionDescription: "Days covered when travelling",
                        quotes: [travelQuote45, travelQuote60]
                    )
                ),
                activeAddons: [],
                baseQuoteCost: .init(premium: .init(gross: .sek(299), net: .sek(299)), discounts: []),
                productVariant: .init(
                    termsVersion: "1.0",
                    typeOfContract: "SE_APARTMENT_RENT",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Rental apartment",
                    displayNameTier: nil,
                    tierDescription: nil
                )
            ),
            currentTotalCost: .init(premium: .init(gross: .sek(299), net: .sek(299)), discounts: []),
            infoMessage: nil
        )

        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in
            travelOffer
        })

        sut = mockService

        let testConfig = AddonConfig(
            contractId: "contractId",
            exposureName: "Test exposure",
            displayName: "Test Insurance"
        )
        let model = ChangeAddonViewModel(config: testConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)
        assert(model.addonOffer == travelOffer)
        assert(model.fetchAddonsViewState == .success)
        assert(model.selectedAddons == [travelQuote45])

        // Select second quote — should replace, not add
        model.selectAddon(addon: travelQuote60)
        assert(model.selectedAddons == [travelQuote60])
        assert(model.selectedAddons.count == 1)

        // Re-select first — still replaces
        model.selectAddon(addon: travelQuote45)
        assert(model.selectedAddons == [travelQuote45])
        assert(model.selectedAddons.count == 1)
    }

    func testFetchAddonOfferFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in
                throw AddonsError.somethingWentWrong
            }
        )

        sut = mockService

        let testConfig = AddonConfig(
            contractId: "contractId",
            exposureName: "Test exposure",
            displayName: "Test Insurance"
        )
        let model = ChangeAddonViewModel(config: testConfig, addonSource: .insurances)

        vm = model

        try await Task.sleep(seconds: 0.03)
        assert(model.addonOffer == nil)
        assert(model.selectedAddons.isEmpty)

        if case let .error(errorMessage) = model.fetchAddonsViewState {
            assert(errorMessage == AddonsError.somethingWentWrong.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    func testSubmitAddonsSuccess() async throws {
        let mockService = MockData.createMockAddonsService(addonsSubmit: { _, _ in
        })

        sut = mockService

        let testConfig = AddonConfig(
            contractId: "contractId",
            exposureName: "Test exposure",
            displayName: "Test Insurance"
        )
        let model = ChangeAddonViewModel(config: testConfig, addonSource: .insurances)

        vm = model
        await model.submitAddons()

        try await Task.sleep(seconds: 0.03)
        assert(model.submittingAddonsViewState == .success)
    }

    func testSubmitAddonsFailure() async throws {
        let mockService = MockData.createMockAddonsService(
            fetchAddonOffer: { _ in
                throw AddonsError.submitError
            },
            addonsSubmit: { _, _ in
                throw AddonsError.submitError
            }
        )

        sut = mockService

        let testConfig = AddonConfig(
            contractId: "contractId",
            exposureName: "Test exposure",
            displayName: "Test Insurance"
        )
        let model = ChangeAddonViewModel(config: testConfig, addonSource: .insurances)

        vm = model
        await model.submitAddons()

        try await Task.sleep(seconds: 0.03)
        if case let .error(errorMessage) = model.submittingAddonsViewState {
            assert(errorMessage == AddonsError.submitError.localizedDescription)
        } else {
            assertionFailure("not proper state")
        }
    }

    // MARK: - Toggleable (car) tests

    func testFetchToggleableAddonOfferSuccess() async throws {
        let fixedDate = Date()

        let carAddonRisk = AddonOfferQuote(
            id: "sjalvriskreducering",
            displayTitle: "Excess reduction",
            displayDescription: "Reduce your excess in case of damage",
            displayItems: [.init(displayTitle: "Coverage", displayValue: "Excess reduction")],
            cost: .init(premium: .init(gross: .sek(59), net: .sek(59)), discounts: []),
            addonVariant: .init(
                displayName: "Excess reduction",
                documents: [],
                perils: [],
                product: "car_addon",
                termsVersion: "1.0"
            ),
            subType: nil
        )
        let carAddonRental = AddonOfferQuote(
            id: "hyrbil",
            displayTitle: "Rental car abroad",
            displayDescription: "Coverage for rental cars abroad",
            displayItems: [.init(displayTitle: "Coverage", displayValue: "Rental car")],
            cost: .init(premium: .init(gross: .sek(39), net: .sek(39)), discounts: []),
            addonVariant: .init(
                displayName: "Rental car abroad",
                documents: [],
                perils: [],
                product: "car_addon",
                termsVersion: "1.0"
            ),
            subType: nil
        )

        let carOffer = AddonOffer(
            pageTitle: "Extend your coverage",
            pageDescription: "Get extra coverage for your car",
            quote: .init(
                quoteId: "carQuoteId1",
                displayTitle: "Car Plus",
                displayDescription: "Extra coverage for your car",
                activationDate: fixedDate,
                addonOffer: .toggleable(.init(quotes: [carAddonRisk, carAddonRental])),
                activeAddons: [],
                baseQuoteCost: .init(premium: .init(gross: .sek(469), net: .sek(469)), discounts: []),
                productVariant: .init(
                    termsVersion: "1.0",
                    typeOfContract: "SE_CAR_FULL",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Car insurance",
                    displayNameTier: nil,
                    tierDescription: nil
                )
            ),
            currentTotalCost: .init(premium: .init(gross: .sek(469), net: .sek(469)), discounts: []),
            infoMessage: nil
        )

        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in
            carOffer
        })

        sut = mockService

        let testConfig = AddonConfig(
            contractId: "contractId",
            exposureName: "Test exposure",
            displayName: "Test Insurance"
        )
        let model = ChangeAddonViewModel(config: testConfig, addonSource: .insurances)

        vm = model
        try await Task.sleep(seconds: 0.03)
        assert(model.addonOffer == carOffer)
        assert(model.fetchAddonsViewState == .success)
        assert(model.selectedAddons.isEmpty)

        // Toggle first addon on
        model.selectAddon(addon: carAddonRisk)
        assert(model.selectedAddons.contains(carAddonRisk))
        assert(model.selectedAddons.count == 1)

        // Toggle second addon on
        model.selectAddon(addon: carAddonRental)
        assert(model.selectedAddons.contains(carAddonRisk))
        assert(model.selectedAddons.contains(carAddonRental))
        assert(model.selectedAddons.count == 2)

        // Toggle first addon off
        model.selectAddon(addon: carAddonRisk)
        assert(!model.selectedAddons.contains(carAddonRisk))
        assert(model.selectedAddons.contains(carAddonRental))
        assert(model.selectedAddons.count == 1)
    }
}
