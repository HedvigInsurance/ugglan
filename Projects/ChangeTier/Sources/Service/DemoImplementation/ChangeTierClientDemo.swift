import Foundation
import hCore
import hGraphQL

public class ChangeTierClientDemo: ChangeTierClient {
    public init() {}

    public func getTier(input: ChangeTierInputData) async throws -> ChangeTierIntentModel {

        let displayItems: [Quote.DisplayItem] = [
            .init(title: "Activation date", subTitle: nil, value: "24 sep 2024"),
            .init(title: "Coverage level", subTitle: nil, value: "Standard"),
            .init(title: "Deductible", subTitle: nil, value: "1750 kr"),
        ]

        let quotes: [Quote] = [
            .init(
                id: "id1",
                quoteAmount: .init(amount: "1000", currency: "SEK"),
                quotePercentage: 0,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "1167", currency: "SEK"),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
                    perils: [
                        .init(
                            id: "id1",
                            title: "title1",
                            description: "description1",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id2",
                            title: "title2",
                            description: "description2",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id3",
                            title: "title3",
                            description: "description3",
                            color: nil,
                            covered: []
                        ),
                    ],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Homeowner",
                    displayNameTier: "Standard",
                    tierDescription: "Vårt mellanpaket med hög ersättning."
                )
            ),
            .init(
                id: "id2",
                quoteAmount: .init(amount: "2000", currency: "SEK"),
                quotePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "999", currency: "SEK"),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
                    perils: [
                        .init(
                            id: "id1",
                            title: "title1",
                            description: "description1",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id2",
                            title: "title2",
                            description: "description2",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id3",
                            title: "title3",
                            description: "description3",
                            color: nil,
                            covered: []
                        ),
                    ],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Homeowner",
                    displayNameTier: "Standard",
                    tierDescription: "Vårt mellanpaket med hög ersättning."
                )
            ),
            .init(
                id: "id3",
                quoteAmount: .init(amount: "3000", currency: "SEK"),
                quotePercentage: 15,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "569", currency: "SEK"),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
                    perils: [
                        .init(
                            id: "id1",
                            title: "title1",
                            description: "description1",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id2",
                            title: "title2",
                            description: "description2",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id3",
                            title: "title3",
                            description: "description3",
                            color: nil,
                            covered: []
                        ),
                    ],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Homeowner",
                    displayNameTier: "Standard",
                    tierDescription: "Vårt mellanpaket med hög ersättning."
                )
            ),
        ]

        let selectedTier = Tier(
            id: "STANDARD",
            name: "Standard",
            level: 2,
            quotes: [
                .init(
                    id: "quote1",
                    quoteAmount: .init(amount: "220", currency: "SEK"),
                    quotePercentage: 0,
                    subTitle: nil,
                    premium: .init(amount: "220", currency: "SEK"),
                    displayItems: [],
                    productVariant: nil
                )
            ],
            exposureName: "Standard"
        )

        return .init(
            displayName: "display name",
            activationDate: Date(),
            tiers: [
                .init(
                    id: "id",
                    name: "Bas",
                    level: 0,
                    quotes: quotes,
                    exposureName: "Bellmansgatan 19A"
                ),
                selectedTier,
                .init(
                    id: "id3",
                    name: "Premium",
                    level: 0,
                    quotes: quotes,
                    exposureName: "Bellmansgatan 19A"
                ),
            ],
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: .init(
                id: "id",
                name: "Max",
                level: 3,
                quotes: quotes,
                exposureName: ""
            ),
            currentQuote: .init(
                id: "id1",
                quoteAmount: .init(amount: "449", currency: "SEK"),
                quotePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "999", currency: "SEK"),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
                    perils: [
                        .init(
                            id: "id1",
                            title: "title1",
                            description: "description1",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id2",
                            title: "title2",
                            description: "description2",
                            color: nil,
                            covered: []
                        ),
                        .init(
                            id: "id3",
                            title: "title3",
                            description: "description3",
                            color: nil,
                            covered: []
                        ),
                    ],
                    insurableLimits: [],
                    documents: [],
                    displayName: "Homeowner",
                    displayNameTier: "Standard",
                    tierDescription: "Vårt mellanpaket med hög ersättning."
                )
            ),
            selectedTier: selectedTier,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seApartmentBrf
        )
    }

    public func commitTier(quoteId: String) async throws {}

    public func compareProductVariants(termsVersion: [String]) async throws -> ProductVariantComparison {
        return .init(
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

            ],
            variantColumns: [
                .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
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
                    partner: nil,
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
                    partner: nil,
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
