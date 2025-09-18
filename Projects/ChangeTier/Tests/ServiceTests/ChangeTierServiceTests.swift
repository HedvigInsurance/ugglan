@preconcurrency import XCTest
import hCore

@testable import ChangeTier

@MainActor
final class ChangeTierServiceTests: XCTestCase {
    weak var sut: MockChangeTierService?

    override func setUp() async throws {
        try await super.setUp()
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
                        currentTotalCost: .init(gross: .sek(229), net: .sek(229)),
                        newTotalCost: .init(gross: .sek(229), net: .sek(229)),
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
                        ),
                        addons: [],
                        costBreakdown: []
                    )
                ],
                exposureName: "exposureName"
            ),
        ]

        let changeTierIntentModel: ChangeTierIntentModel = .init(
            displayName: "displayName",
            activationDate: Date(),
            tiers: tiers,
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

        sut = mockService

        let respondedTiersData = try! await mockService.getTier(
            input: .init(source: .changeTier, contractId: "contractId")
        )
        assert(respondedTiersData == changeTierIntentModel)
    }

    func testCompareProductVariantDataSuccess() async {
        let rows: [ProductVariantComparison.ProductVariantComparisonRow] = [
            .init(
                title: "rowTitle",
                description: "description",
                colorCode: nil,
                cells: [
                    .init(isCovered: true, coverageText: nil)
                ]
            )
        ]

        let columns: [ProductVariant] = [
            .init(
                termsVersion: "",
                typeOfContract: "",
                partner: "",
                perils: [],
                insurableLimits: [],
                documents: [],
                displayName: "",
                displayNameTier: "Standard",
                tierDescription: "tier description"
            )
        ]

        let comparisonData = ProductVariantComparison(rows: rows, variantColumns: columns)

        let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
            comparisonData
        })

        sut = mockService

        let responedComparisonData = try! await mockService.compareProductVariants(termsVersion: [])

        assert(responedComparisonData == comparisonData)
    }
}
