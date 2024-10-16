import XCTest
import hCore

@testable import ChangeTier

final class ChangeTierServiceTests: XCTestCase {
    weak var sut: MockChangeTierService?

    override func setUp() {
        super.setUp()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ChangeTierClient.self)
        try await Task.sleep(nanoseconds: 100)

        XCTAssertNil(sut)
    }

    func testFetchTierDataSuccess() async {
        let tiers: [Tier] = [
            .init(
                id: "id1",
                name: "standard",
                level: 1,
                quotes: [],
                exposureName: "exposureName"
            ),
            .init(
                id: "id2",
                name: "max",
                level: 2,
                quotes: [
                    .init(
                        id: "id1",
                        quoteAmount: nil,
                        quotePercentage: nil,
                        subTitle: nil,
                        premium: .init(amount: "229", currency: "SEK"),
                        displayItems: [],
                        productVariant: .init(
                            termsVersion: "",
                            typeOfContract: "",
                            partner: nil,
                            perils: [],
                            insurableLimits: [],
                            documents: [],
                            displayName: "",
                            displayNameTier: nil,
                            tierDescription: nil
                        )
                    )
                ],
                exposureName: "exposureName"
            ),
        ]

        let changeTierIntentModel: ChangeTierIntentModel = .init(
            displayName: "displayName",
            activationDate: Date(),
            tiers: tiers,
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: nil,
            currentQuote: nil,
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seHouse
        )

        let mockService = MockData.createMockChangeTier(fetchTier: { _ in
            changeTierIntentModel
        })

        self.sut = mockService

        let respondedTiersData = try! await mockService.getTier(
            input: .init(source: .changeTier, contractId: "contractId")
        )
        assert(respondedTiersData == changeTierIntentModel)
    }
}
