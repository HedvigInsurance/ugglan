@preconcurrency import XCTest
import hCore

@testable import ChangeTier
@testable import hCoreUI

@MainActor
final class CompareTierVireModelTests: XCTestCase {
    weak var sut: MockChangeTierService?
    weak var vm: CompareTierViewModel?

    let currentTier = Tier(
        id: "currentTier",
        name: "current tier",
        level: 1,
        quotes: [],
        exposureName: nil
    )
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
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "displayName",
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

    override func setUp() async throws {
        try await super.setUp()
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ChangeTierClient.self)
        try await Task.sleep(seconds: 0.02)
        XCTAssertNil(sut)
        XCTAssertNil(vm)
    }

    func testCompareTiersSuccess() async throws {
        let peril1 = Perils(
            id: "peril1",
            title: "peril1",
            description: "description",
            color: nil,
            covered: [""],
            isDisabled: false
        )

        let rows: [ProductVariantComparison.ProductVariantComparisonRow] = [
            .init(
                title: peril1.title,
                description: peril1.description,
                colorCode: peril1.color,
                cells: [
                    .init(isCovered: !peril1.isDisabled, coverageText: peril1.covered.first),
                    .init(isCovered: !peril1.isDisabled, coverageText: peril1.covered.first),
                ]
            )
        ]

        let columns: [ProductVariant] = [
            .init(
                termsVersion: "",
                typeOfContract: "",
                perils: [peril1],
                insurableLimits: [],
                documents: [],
                displayName: "",
                displayNameTier: "Standard",
                tierDescription: "tier description"
            ),
            .init(
                termsVersion: "",
                typeOfContract: "",
                perils: [peril1],
                insurableLimits: [],
                documents: [],
                displayName: "",
                displayNameTier: "Max",
                tierDescription: "tier description"
            ),
        ]

        let comparisonData = ProductVariantComparison(rows: rows, variantColumns: columns)

        let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
            comparisonData
        })

        sut = mockService

        let model = CompareTierViewModel(tiers: tiers)
        vm = model
        model.productVariantComparision()

        try await Task.sleep(seconds: 0.03)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.perils.first! == ("Standard", [peril1]))
        assert(model.viewState == .success)
    }

    func testCompareTiersFailure() async throws {
        let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
            throw ChangeTierError.somethingWentWrong
        })

        sut = mockService

        let model = CompareTierViewModel(tiers: tiers)
        vm = model
        model.productVariantComparision()

        try await Task.sleep(seconds: 0.03)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.perils.isEmpty)
        assert(model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription))
    }
}
