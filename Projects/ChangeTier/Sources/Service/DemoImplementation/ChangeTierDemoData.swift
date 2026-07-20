import Foundation
import hCore

// Shared demo/preview fixtures for the ChangeTier module. Centralised here so the
// demo client and SwiftUI previews reuse the same literals instead of copy-pasting them.
extension Premium {
    static var demo: Premium {
        .init(
            gross: .init(amount: "200", currency: "SEK"),
            net: .init(amount: "160", currency: "SEK")
        )
    }
}

extension ProductVariant {
    static var demoStandard: ProductVariant {
        .init(
            termsVersion: "",
            typeOfContract: "",
            perils: (1...3)
                .map { index in
                    .init(
                        id: "id\(index)",
                        title: "title\(index)",
                        description: "description\(index)",
                        color: nil,
                        covered: []
                    )
                },
            insurableLimits: [],
            documents: [],
            displayName: "Homeowner",
            displayNameTier: "Standard",
            tierDescription: "Vårt mellanpaket med hög ersättning."
        )
    }
}

extension Quote {
    /// Deductible-free quote used by previews.
    static func demo(id: String = "quote1") -> Quote {
        .init(
            id: id,
            quoteAmount: .init(amount: "220", currency: "SEK"),
            quotePercentage: 0,
            subTitle: nil,
            currentTotalCost: .demo,
            newTotalCost: .demo,
            displayItems: [],
            productVariant: nil,
            addons: [],
            costBreakdown: []
        )
    }

    /// Quote carrying a full product variant, used by the demo client.
    static func demoWithVariant(
        id: String,
        amount: String,
        percentage: Int,
        displayItems: [Quote.DisplayItem]
    ) -> Quote {
        .init(
            id: id,
            quoteAmount: .init(amount: amount, currency: "SEK"),
            quotePercentage: percentage,
            subTitle: "Endast en rörlig del om 25% av skadekostnaden.",
            currentTotalCost: .demo,
            newTotalCost: .demo,
            displayItems: displayItems,
            productVariant: .demoStandard,
            addons: [],
            costBreakdown: []
        )
    }
}

extension Tier {
    /// Tier holding a single deductible-free quote, used by previews.
    static func demo(id: String, name: String, level: Int, description: String?, exposureName: String?) -> Tier {
        .init(
            id: id,
            name: name,
            level: level,
            description: description,
            quotes: [.demo()],
            exposureName: exposureName
        )
    }
}
