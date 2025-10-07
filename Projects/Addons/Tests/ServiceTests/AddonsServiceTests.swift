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
        let addonModel: AddonOffer = .init(
            titleDisplayName: "title",
            description: "description",
            activationDate: Date(),
            currentAddon: nil,
            quotes: [
                .init(
                    displayName: "option title",
                    displayNameLong: "option title long",
                    quoteId: "quoteId1",
                    addonId: "addonId1",
                    addonSubtype: "addonSubtype1",
                    displayItems: [],
                    itemCost: .init(premium: .init(gross: .sek(49), net: .sek(49)), discounts: []),
                    addonVariant: .init(
                        displayName: "displayName",
                        documents: [],
                        perils: [],
                        product: "",
                        termsVersion: ""
                    ),
                    documents: []
                ),
                .init(
                    displayName: "option title",
                    displayNameLong: "option title long",
                    quoteId: "quoteId2",
                    addonId: "addonId2",
                    addonSubtype: "addonSubtype2",
                    displayItems: [],
                    itemCost: .init(premium: .init(gross: .sek(79), net: .sek(79)), discounts: []),
                    addonVariant: .init(
                        displayName: "displayName2",
                        documents: [],
                        perils: [],
                        product: "",
                        termsVersion: ""
                    ),
                    documents: []
                ),
            ]
        )

        let mockService = MockData.createMockAddonsService(fetchAddon: { _ in
            addonModel
        })

        sut = mockService

        let respondedAddonData = try await mockService.getAddon(contractId: "contractId")

        assert(respondedAddonData == addonModel)
    }
}
