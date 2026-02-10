@preconcurrency import XCTest
import hCore

@testable import Addons

@MainActor
final class AddonsServiceTests: XCTestCase {
    weak var sut: MockAddonsService?

    override func tearDown() async throws {
        try await super.tearDown()
        Dependencies.shared.remove(for: AddonsClient.self)
        XCTAssertNil(sut)
    }

    func testFetchAddonDataSuccess() async throws {
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
            subType: "45 days",
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
            infoMessage: nil,
        )

        let mockService = MockData.createMockAddonsService(fetchAddonOffer: { _ in
            travelOffer
        })

        sut = mockService

        let respondedAddonData = try await mockService.getAddonOffer(contractId: "contractId")

        assert(respondedAddonData == travelOffer)
    }

    func testGetAddonBannersSuccess() async throws {
        let testBanner = AddonBanner(
            contractIds: ["contractId"],
            titleDisplayName: "Travel Plus",
            descriptionDisplayName: "Extended travel insurance with extra coverage",
            badges: ["Popular"]
        )

        let mockService = MockData.createMockAddonsService(fetchBanners: { _ in
            [testBanner]
        })

        sut = mockService

        let respondedBanners = try await mockService.getAddonBanners(source: .insurances)

        assert(respondedBanners == [testBanner])
        assert(respondedBanners.first?.titleDisplayName == "Travel Plus")
    }
}
