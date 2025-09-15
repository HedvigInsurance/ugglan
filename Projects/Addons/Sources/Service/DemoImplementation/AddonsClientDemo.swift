import Foundation

public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon(contractId _: String) async throws -> AddonOffer {
        let currentAddon: AddonQuote = .init(
            displayName: "45 days",
            displayNameLong: "display name long",
            quoteId: "quoteId45",
            addonId: "addonId45",
            addonSubtype: "addonSubtype45",
            displayItems: [
                .init(displayTitle: "Coverage", displayValue: "45 days"),
                .init(displayTitle: "Insured people", displayValue: "You+1"),
            ],
            price: .init(gross: .sek(69), net: .sek(49)),
            addonVariant: nil,
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
                    displayNameLong: "display name long",
                    quoteId: "quoteId60",
                    addonId: "addonId60",
                    addonSubtype: "addonSubtype60",
                    displayItems: [
                        .init(displayTitle: "Coverage", displayValue: "60 days"),
                        .init(displayTitle: "Insured people", displayValue: "You+1"),
                    ],
                    price: .init(gross: .sek(79), net: .sek(59)),
                    addonVariant: .init(
                        displayName: "",
                        documents: [],
                        perils: [],
                        product: "",
                        termsVersion: ""
                    ),
                    documents: []
                ),
            ]
        )

        return addons
    }

    public func submitAddon(quoteId _: String, addonId _: String) async throws {}
}
