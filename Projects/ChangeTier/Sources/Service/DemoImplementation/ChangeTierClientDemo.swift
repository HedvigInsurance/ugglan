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
                .init(
                    id: "i2",
                    name: "Standard",
                    level: 0,
                    quotes: quotes,
                    exposureName: "Bellmansgatan 19A"
                ),
                .init(
                    id: "id3",
                    name: "Max",
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
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seApartmentBrf
        )
    }

    public func commitTier(quoteId: String) async throws {}
}
