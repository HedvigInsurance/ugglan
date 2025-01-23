import Foundation

public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon(contractId: String) async throws -> AddonOffer {
        let currentAddon: AddonQuote = .init(
            displayName: "45 days",
            quoteId: "quoteId45",
            addonId: "addonId45",
            displayItems: [
                .init(displayTitle: "Coverage", displayValue: "45 days"),
                .init(displayTitle: "Insured people", displayValue: "You+1"),
            ],
            price: .init(amount: "49", currency: "SEK"),
            addonVariant: nil
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
                    )
                ),
            ]
        )

        return addons
    }

    public func submitAddon(quoteId: String, addonId: String) async throws {}
}
