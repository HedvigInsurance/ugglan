import Foundation
import hCore

public class SelectTierClientOctopus: SelectTierClient {
    public init() {}

    public func getTier() async throws -> ChangeTierIntentModel {
        /* TODO: REPLACE WITH REAL DATA */
        // for all tierQuotes with tierLevel = X, fetch all deductible info and add as deductible
        return .init(
            id: "id",
            activationDate: Date(),
            tiers: [
                .init(
                    id: "id",
                    name: "Bas",
                    level: 0,
                    deductibles: [
                        .init(
                            id: "id",
                            deductibleAmount: .init(amount: "1000", currency: "SEK"),
                            deductiblePercentage: 0,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "1167", currency: "SEK")
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "999", currency: "SEK")
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "569", currency: "SEK")
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [
                        .init(id: "id1", title: "Activation date", subTitle: nil, value: "24 sep 2024"),
                        .init(id: "id2", title: "Coverage level", subTitle: nil, value: "Standard"),
                        .init(id: "id3", title: "Deductible", subTitle: nil, value: "1750 kr"),
                    ],
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
                        displayNameTierLong: "Vårt mellanpaket med hög ersättning."
                    )
                ),
                .init(
                    id: "i2",
                    name: "Standard",
                    level: 0,
                    deductibles: [
                        .init(
                            id: "id",
                            deductibleAmount: .init(amount: "1000", currency: "SEK"),
                            deductiblePercentage: 0,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "1167", currency: "SEK")
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "999", currency: "SEK")
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "569", currency: "SEK")
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [
                        .init(id: "id1", title: "Activation date", subTitle: nil, value: "24 sep 2024"),
                        .init(id: "id2", title: "Coverage level", subTitle: nil, value: "Standard"),
                        .init(id: "id3", title: "Deductible", subTitle: nil, value: "1750 kr"),
                    ],
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
                        displayNameTierLong: "Vårt mellanpaket med hög ersättning."
                    )
                ),
                .init(
                    id: "id3",
                    name: "Max",
                    level: 0,
                    deductibles: [
                        .init(
                            id: "id",
                            deductibleAmount: .init(amount: "1000", currency: "SEK"),
                            deductiblePercentage: 0,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "1167", currency: "SEK")
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "999", currency: "SEK")
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15,
                            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
                            premium: .init(amount: "569", currency: "SEK")
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [
                        .init(id: "id1", title: "Activation date", subTitle: nil, value: "24 sep 2024"),
                        .init(id: "id2", title: "Coverage level", subTitle: nil, value: "Standard"),
                        .init(id: "id3", title: "Deductible", subTitle: nil, value: "1750 kr"),
                    ],
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
                        displayNameTierLong: "Vårt mellanpaket med hög ersättning."
                    )
                ),
            ],
            currentPremium: .init(amount: "449", currency: "SEK")
        )
    }
}
