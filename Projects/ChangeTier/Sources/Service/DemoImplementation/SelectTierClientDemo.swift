import Foundation
import hCore
import hGraphQL

public class SelectTierClientDemo: SelectTierClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getTier() async throws -> ChangeTierIntentModel {
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
                            deductiblePercentage: 0
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [],
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "Homeowner",
                        displayNameTier: "Standard",
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
                            deductiblePercentage: 0
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [],
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
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
                            deductiblePercentage: 0
                        ),
                        .init(
                            id: "id2",
                            deductibleAmount: .init(amount: "2000", currency: "SEK"),
                            deductiblePercentage: 25
                        ),
                        .init(
                            id: "id3",
                            deductibleAmount: .init(amount: "3000", currency: "SEK"),
                            deductiblePercentage: 15
                        ),
                    ],
                    premium: .init(amount: "530", currency: "SEK"),
                    displayItems: [],
                    exposureName: "Bellmansgatan 19A",
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [],
                        documents: [],
                        displayName: "Homeowner",
                        displayNameTier: "Standard",
                        displayNameTierLong: "Vårt mellanpaket med hög ersättning."
                    )
                ),
            ],
            currentPremium: .init(amount: "449", currency: "SEK")
        )
    }
}
