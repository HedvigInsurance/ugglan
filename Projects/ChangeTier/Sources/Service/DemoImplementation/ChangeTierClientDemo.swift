import Foundation
import hCore

public class ChangeTierClientDemo: ChangeTierClient {
    public init() {}

    public func getTier(input _: ChangeTierInputData) async throws -> ChangeTierIntentModelState {
        let displayItems: [Quote.DisplayItem] = [
            .init(title: "Activation date", value: "24 sep 2024"),
            .init(title: "Coverage level", value: "Standard"),
            .init(title: "Deductible", value: "1750 kr"),
        ]

        let quotes: [Quote] = [
            .demoWithVariant(id: "id1", amount: "1000", percentage: 0, displayItems: displayItems),
            .demoWithVariant(id: "id2", amount: "2000", percentage: 25, displayItems: displayItems),
            .demoWithVariant(id: "id3", amount: "3000", percentage: 15, displayItems: displayItems),
        ]

        let selectedTier = Tier.demo(
            id: "STANDARD",
            name: "Standard",
            level: 2,
            description: "desc1",
            exposureName: "Standard"
        )

        return .changeTierIntentModel(
            changeTierIntentModel: .init(
                displayName: "display name",
                activationDate: Date(),
                tiers: [
                    .init(
                        id: "id",
                        name: "Bas",
                        level: 0,
                        description: "desc1",
                        quotes: quotes,
                        exposureName: "Bellmansgatan 19A"
                    ),
                    selectedTier,
                    .init(
                        id: "id3",
                        name: "Premium",
                        level: 0,
                        description: "desc1",
                        quotes: quotes,
                        exposureName: "Bellmansgatan 19A"
                    ),
                ],
                currentTier: .init(
                    id: "id",
                    name: "Max",
                    level: 3,
                    description: "desc1",
                    quotes: quotes,
                    exposureName: ""
                ),
                currentQuote: .demoWithVariant(
                    id: "id1",
                    amount: "449",
                    percentage: 25,
                    displayItems: displayItems
                ),
                selectedTier: selectedTier,
                selectedQuote: nil,
                canEditTier: true,
                typeOfContract: .seApartmentBrf,
                relatedAddons: [:]
            )
        )
    }

    public func commitTier(quoteId _: String) async throws {}

    public func compareProductVariants(termsVersion _: [String]) async throws -> ProductVariantComparison {
        .init(
            rows: [
                .init(
                    title: "Veterinary care",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: true, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                    ]
                ),

                .init(
                    title: "Hidden defects",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                    ]
                ),

                .init(
                    title: "Giving birth",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                    ]
                ),
                .init(
                    title: "Food",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                    ]
                ),
                .init(
                    title: "Dental care",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: true, coverageText: ""),
                    ]
                ),
                .init(
                    title: "Your belongings in your home",
                    description: "description",
                    colorCode: nil,
                    cells: [
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: false, coverageText: ""),
                        .init(isCovered: true, coverageText: "3 000 000 kr"),
                    ]
                ),

            ],
            variantColumns: [
                .init(
                    termsVersion: "",
                    typeOfContract: "",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Bas",
                    displayNameTier: "Bas",
                    tierDescription: nil
                ),
                .init(
                    termsVersion: "",
                    typeOfContract: "",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Standard",
                    displayNameTier: "Standard",
                    tierDescription: nil
                ),
                .init(
                    termsVersion: "",
                    typeOfContract: "",
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Premium",
                    displayNameTier: "Premium",
                    tierDescription: nil
                ),
            ]
        )
    }
}
