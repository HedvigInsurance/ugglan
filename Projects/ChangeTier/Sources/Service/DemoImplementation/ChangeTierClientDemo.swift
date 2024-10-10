import Foundation
import hCore
import hGraphQL

public class ChangeTierClientDemo: ChangeTierClient {
    public init() {}

    public func getTier(input: ChangeTierInput) async throws(ChangeTierError) -> ChangeTierIntentModel {

        let deductibles: [Deductible] = [
            .init(
                deductibleAmount: .init(amount: "1000", currency: "SEK"),
                deductiblePercentage: 0,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "1167", currency: "SEK")
            ),
            .init(
                deductibleAmount: .init(amount: "2000", currency: "SEK"),
                deductiblePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "999", currency: "SEK")
            ),
            .init(
                deductibleAmount: .init(amount: "3000", currency: "SEK"),
                deductiblePercentage: 15,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "569", currency: "SEK")
            ),
        ]

        let displayItems: [Tier.TierDisplayItem] = [
            .init(title: "Activation date", subTitle: nil, value: "24 sep 2024"),
            .init(title: "Coverage level", subTitle: nil, value: "Standard"),
            .init(title: "Deductible", subTitle: nil, value: "1750 kr"),
        ]

        return .init(
            activationDate: Date(),
            tiers: [
                .init(
                    id: "id",
                    name: "Bas",
                    level: 0,
                    deductibles: deductibles,
                    displayItems: displayItems,
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [
                            .init(
                                id: "id1",
                                title: "title1",
                                description: "description1",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id2",
                                title: "title2",
                                description: "description2",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id3",
                                title: "title3",
                                description: "description3",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                        ],
                        insurableLimits: [],
                        documents: [],
                        displayName: "Homeowner",
                        displayNameTier: "Bas",
                        tierDescription: "Vårt mellanpaket med hög ersättning."
                    ),
                    FAQs: [
                        .init(title: "question 1", description: "..."),
                        .init(title: "question 2", description: "..."),
                        .init(title: "question 3", description: "..."),
                    ]
                ),
                .init(
                    id: "i2",
                    name: "Standard",
                    level: 0,
                    deductibles: deductibles,
                    displayItems: displayItems,
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [
                            .init(
                                id: "id1",
                                title: "title1",
                                description: "description1",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id2",
                                title: "title2",
                                description: "description2",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id3",
                                title: "title3",
                                description: "description3",
                                info: nil,
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
                    FAQs: [
                        .init(title: "question 1", description: "..."),
                        .init(title: "question 2", description: "..."),
                        .init(title: "question 3", description: "..."),
                    ]
                ),
                .init(
                    id: "id3",
                    name: "Max",
                    level: 0,
                    deductibles: deductibles,
                    displayItems: displayItems,
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [
                            .init(
                                id: "id1",
                                title: "title1",
                                description: "description1",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id2",
                                title: "title2",
                                description: "description2",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                            .init(
                                id: "id3",
                                title: "title3",
                                description: "description3",
                                info: nil,
                                color: nil,
                                covered: []
                            ),
                        ],
                        insurableLimits: [],
                        documents: [],
                        displayName: "Homeowner",
                        displayNameTier: "Max",
                        tierDescription: "Vårt mellanpaket med hög ersättning."
                    ),
                    FAQs: [
                        .init(title: "question 1", description: "..."),
                        .init(title: "question 2", description: "..."),
                        .init(title: "question 3", description: "..."),
                    ]
                ),
            ],
            currentPremium: .init(amount: "449", currency: "SEK"),
            currentTier: .init(
                id: "id",
                name: "Max",
                level: 3,
                deductibles: deductibles,
                displayItems: [],
                exposureName: "",
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: "",
                    perils: [],
                    insurableLimits: [
                        .init(label: "label", limit: "limit", description: "description")
                    ],
                    documents: [],
                    displayName: "",
                    displayNameTier: "",
                    tierDescription: ""
                ),
                FAQs: [
                    .init(title: "question 1", description: "..."),
                    .init(title: "question 2", description: "..."),
                    .init(title: "question 3", description: "..."),
                ]
            ),
            currentDeductible: .init(
                deductibleAmount: .init(amount: "449", currency: "SEK"),
                deductiblePercentage: 25,
                subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                premium: .init(amount: "999", currency: "SEK")
            ),
            canEditTier: true
        )
    }

    public func commitTier(quoteId: String) async throws(ChangeTierError) {}
}
