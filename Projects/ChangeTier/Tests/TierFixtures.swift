import Foundation
import hCore

@testable import ChangeTier

/// Tier data shared by the ChangeTier suites, so each suite doesn't carry its own copy.
@MainActor
enum TierFixtures {
    static let currentTier = Tier(
        id: "currentTier",
        name: "current tier",
        level: 1,
        description: nil,
        quotes: [],
        exposureName: nil
    )
    static let tiers: [Tier] = [
        .init(
            id: "id1",
            name: "standard",
            level: 1,
            description: nil,
            quotes: [],
            exposureName: "exposureName"
        ),
        .init(
            id: "id2",
            name: "max",
            level: 2,
            description: nil,
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

    static func intent(
        contractId: String = "contractId",
        activationDate: Date,
        currentTier: Tier? = TierFixtures.currentTier
    ) -> ChangeTierIntentModel {
        .init(
            contractId: contractId,
            displayName: "display name",
            activationDate: activationDate,
            tiers: tiers,
            currentTier: currentTier,
            currentQuote: nil,
            selectedTier: nil,
            selectedQuote: nil,
            canEditTier: true,
            typeOfContract: .seHouse,
            relatedAddons: [:]
        )
    }
}
