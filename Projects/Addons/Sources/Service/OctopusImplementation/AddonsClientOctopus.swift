import Foundation
import hCore
import hGraphQL

@MainActor
public class AddonsService {
    @Inject var service: AddonsClient

    public func getAddon(contractId: String) async throws -> AddonOffer {
        log.info("AddonsService: getAddon", error: nil, attributes: nil)
        return try await service.getAddon(contractId: contractId)
    }

    public func submitAddon(quoteId: String, addonId: String) async throws -> Date? {
        log.info("AddonsService: submitAddon", error: nil, attributes: nil)
        return try await service.submitAddon(quoteId: quoteId, addonId: addonId)
    }
}

public class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getAddon(contractId: String) async throws -> AddonOffer {
        let currentAddon: AddonQuote = .init(
            id: "45",
            displayName: "45 days",
            quoteId: "quoteId45",
            addonId: "addonId45",
            displayItems: [
                .init(displayTitle: "Coverage", displaySubtitle: nil, displayValue: "45 days"),
                .init(displayTitle: "Insured people", displaySubtitle: nil, displayValue: "You+1"),
            ],
            price: .init(amount: "49", currency: "SEK"),
            productVariant: .init(
                termsVersion: "",
                typeOfContract: "",
                partner: nil,
                perils: [],
                insurableLimits: [
                    .init(label: "limit1", limit: "limit1", description: "description"),
                    .init(label: "limit2", limit: "limit2", description: "description"),
                    .init(label: "limit3", limit: "limit3", description: "description"),
                    .init(label: "limit4", limit: "limit4", description: "description"),
                ],
                documents: [
                    .init(displayName: "dodument1", url: "", type: .generalTerms),
                    .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                    .init(displayName: "dodument3", url: "", type: .preSaleInfo),
                ],
                displayName: "display name",
                displayNameTier: nil,
                tierDescription: nil
            )
        )

        let addons: AddonOffer = .init(
            titleDisplayName: "Travel Plus",
            description: "Extended travel insurance with extra coverage for your travels",
            activationDate: "2025-01-15".localDateToDate,
            currentAddon: currentAddon,
            quotes: [
                currentAddon,
                .init(
                    id: "60",
                    displayName: "60 days",
                    quoteId: "quoteId60",
                    addonId: "addonId60",
                    displayItems: [
                        .init(displayTitle: "Coverage", displaySubtitle: nil, displayValue: "45 days"),
                        .init(displayTitle: "Insured people", displaySubtitle: nil, displayValue: "You+1"),
                    ],
                    price: .init(amount: "79", currency: "SEK"),
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [
                            .init(label: "limit1", limit: "limit1", description: "description"),
                            .init(label: "limit2", limit: "limit2", description: "description"),
                            .init(label: "limit3", limit: "limit3", description: "description"),
                            .init(label: "limit4", limit: "limit4", description: "description"),
                        ],
                        documents: [
                            .init(displayName: "dodument1", url: "", type: .generalTerms),
                            .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                            .init(displayName: "dodument3", url: "", type: .preSaleInfo),
                        ],
                        displayName: "Travel Plus",
                        displayNameTier: nil,
                        tierDescription: nil
                    )
                ),
            ]
        )

        return addons
    }

    public func submitAddon(quoteId: String, addonId: String) async throws -> Date? {
        /* TODO: Call mutation upsellTravelAddonActivate(quoteId: ID!, addonId: ID!) */
        return "2025-01-15".localDateToDate
    }
}
