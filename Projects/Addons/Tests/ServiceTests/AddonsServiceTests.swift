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
            quotes: [
                .init(
                    id: "quoteId1",
                    displayName: "option title",
                    quoteId: "quoteId1",
                    addonId: "addonId1",
                    price: .init(amount: "49", currency: "SEK"),
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "display name",
                        displayNameTier: "tier name",
                        tierDescription: nil
                    )
                ),
                .init(
                    id: "quoteId2",
                    displayName: "option title",
                    quoteId: "quoteId2",
                    addonId: "addonId2",
                    price: .init(amount: "79", currency: "SEK"),
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "display name",
                        displayNameTier: "tier name",
                        tierDescription: nil
                    )
                ),
            ]
        )

        let mockService = MockData.createMockAddonsService(fetchAddon: { contractId in
            addonModel
        })

        self.sut = mockService

        let respondedAddonData = try await mockService.getAddon(contractId: "contractId")

        assert(respondedAddonData == addonModel)
    }
}
