import Foundation
import hCore

public class ChangeTierClientDemo: ChangeTierClient {
    public init() {}

    public func getTier(input _: ChangeTierInputData) async throws -> ChangeTierIntentModel {
        let displayItems: [Quote.DisplayItem] = [
            .init(title: "Activation date", value: "24 sep 2024"),
            .init(title: "Coverage level", value: "Standard"),
            .init(title: "Deductible", value: "1750 kr"),
        ]

        let quotes: [Quote] = [
            .init(
                id: "id1",
                quoteAmount: .init(amount: "1000", currency: "SEK"),
                quotePercentage: 0,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                currentTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                newTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
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
                ),
                addons: [],
                costBreakdown: []
            ),
            .init(
                id: "id2",
                quoteAmount: .init(amount: "2000", currency: "SEK"),
                quotePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                currentTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                newTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
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
                ),
                addons: [],
                costBreakdown: []
            ),
            .init(
                id: "id3",
                quoteAmount: .init(amount: "3000", currency: "SEK"),
                quotePercentage: 15,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                currentTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                newTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
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
                ),
                addons: [],
                costBreakdown: []
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
                    currentTotalCost: .init(
                        gross: .init(amount: "200", currency: "SEK"),
                        net: .init(amount: "160", currency: "SEK"),
                    ),
                    newTotalCost: .init(
                        gross: .init(amount: "200", currency: "SEK"),
                        net: .init(amount: "160", currency: "SEK"),
                    ),
                    displayItems: [],
                    productVariant: nil,
                    addons: [],
                    costBreakdown: []
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
                currentTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                newTotalCost: .init(
                    gross: .init(amount: "200", currency: "SEK"),
                    net: .init(amount: "160", currency: "SEK"),
                ),
                displayItems: displayItems,
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
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
                ),
                addons: [],
                costBreakdown: []
            ),
            selectedTier: selectedTier,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seApartmentBrf,
            relatedAddons: [:]
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
