import Foundation

public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon(contractId _: String) async throws -> AddonOffer {
        let currentAddon: AddonQuote = .init(
            displayName: "45 days",
            quoteId: "quoteId45",
            addonId: "addonId45",
            addonSubtype: "addonSubtype45",
            displayItems: [
                .init(displayTitle: "Coverage", displayValue: "45 days"),
                .init(displayTitle: "Insured people", displayValue: "You+1"),
            ],
            price: .init(amount: "49", currency: "SEK"),
            addonVariant: nil,
            discountDisplayItems: [
                .init(displayTitle: "Travel Plus 60 days", displayValue: "79 kr/mo"),
                .init(displayTitle: "15% bundle discount", displayValue: "-19 kr/mo"),
            ],
            documents: []
        )

        let addons: AddonOffer = .init(
            titleDisplayName: "Travel Plus",
            description: "Extended travel insurance with extra coverage for your travels",
            activationDate: "2025-01-15".localDateToDate,
            currentAddon: currentAddon,
            quotes: [
                currentAddon,
                .init(
                    displayName: "60 days",
                    quoteId: "quoteId60",
                    addonId: "addonId60",
                    addonSubtype: "addonSubtype60",
                    displayItems: [
                        .init(displayTitle: "Coverage", displayValue: "60 days"),
                        .init(displayTitle: "Insured people", displayValue: "You+1"),
                    ],
                    price: .init(amount: "79", currency: "SEK"),
                    addonVariant: .init(
                        displayName: "",
                        documents: [],
                        perils: [],
                        product: "",
                        termsVersion: ""
                    ),
                    discountDisplayItems: [
                        .init(displayTitle: "Travel Plus 60 days", displayValue: "79 kr/mo"),
                        .init(displayTitle: "15% bundle discount", displayValue: "-19 kr/mo"),
                    ],
                    documents: []
                ),
            ]
        )

        return addons
    }

    public func submitAddon(quoteId _: String, addonId _: String) async throws {}
}
