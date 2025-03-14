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
                    basePremium: .init(amount: "229", currency: "SEK"),
                    displayItems: [],
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "displayName",
                        displayNameTier: nil,
                        tierDescription: nil
                    ),
                    addons: []
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
        try await Task.sleep(nanoseconds: 20_000_000)
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
                partner: "",
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
                partner: "",
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

        self.sut = mockService

        let model = CompareTierViewModel(tiers: tiers)
        self.vm = model
        model.productVariantComparision()

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.perils.first! == ("standard", [peril1]))
        assert(model.viewState == .success)
    }

    func testCompareTiersFailure() async throws {
        let mockService = MockData.createMockChangeTier(compareProductVariants: { _ in
            throw ChangeTierError.somethingWentWrong
        })

        self.sut = mockService

        let model = CompareTierViewModel(tiers: tiers)
        self.vm = model
        model.productVariantComparision()

        try await Task.sleep(nanoseconds: 30_000_000)
        assert(model.tiers == tiers)
        assert(model.tiers.first == tiers.first)
        assert(model.tiers.count == tiers.count)
        assert(model.perils.isEmpty)
        assert(model.viewState == .error(errorMessage: ChangeTierError.somethingWentWrong.localizedDescription))
    }
}
