import Addons
import hCore
import hGraphQL

class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    func getAddon(contractId: String) async throws -> AddonOffer {
        do {
            let mutation = OctopusGraphQL.UpsellTravelAddonOfferMutation(contractId: contractId)

            let addonOfferData = try await octopus.client.perform(mutation: mutation)
            let response = addonOfferData.upsellTravelAddonOffer

            if let error = response.userError, let message = error.message {
                throw AddonsError.errorMessage(message: message)
            }

            guard let addonOffer = response.offer else {
                throw AddonsError.somethingWentWrong
            }

            let currentAddon: AddonQuote? = {
                guard let currentAddon = addonOffer.currentAddon else { return nil }

                return .init(
                    displayName: "",
                    displayNameLong: currentAddon.displayNameLong,
                    quoteId: "quoteId",
                    addonId: "addonId",
                    addonSubtype: "addonSubtype",
                    displayItems: currentAddon.displayItems.map {
                        .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment)
                    },
                    itemCost: .init(
                        premium: .init(
                            gross: nil,
                            net: .init(fragment: currentAddon.netPremium.fragments.moneyFragment)
                        ),
                        discounts: []
                    ),
                    addonVariant: nil,
                    documents: []
                )
            }()
            let addonData = AddonOffer(
                titleDisplayName: addonOffer.titleDisplayName,
                description: addonOffer.descriptionDisplayName,
                activationDate: addonOffer.activationDate.localDateToDate,
                currentAddon: currentAddon,
                quotes: addonOffer.quotes.map { quote in
                    .init(fragment: quote.fragments.upsellTravelAddonQuoteFragment)
                }
            )

            return addonData
        } catch let exception {
            if let exception = exception as? AddonsError {
                throw exception
            }
            throw AddonsError.somethingWentWrong
        }
    }

    func submitAddon(quoteId: String, addonId: String) async throws {
        do {
            let mutation = OctopusGraphQL.UpsellTravelAddonActivateMutation(quoteId: quoteId, addonId: addonId)
            let delayTask = Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            }
            let response = try await octopus.client.perform(mutation: mutation)
            try await delayTask.value
            if let error = response.upsellTravelAddonActivate.userError, let message = error.message {
                throw AddonsError.errorMessage(message: message)
            }
        } catch let exception {
            if let exception = exception as? AddonsError {
                throw exception
            }
            throw AddonsError.somethingWentWrong
        }
    }
}

extension AddonQuote {
    init(
        fragment: OctopusGraphQL.UpsellTravelAddonQuoteFragment
    ) {
        let displayItems: [AddonDisplayItem] = fragment.displayItems.map {
            .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment)
        }
        let documents = fragment.documents.compactMap { document in
            hPDFDocument(displayName: document.displayName, url: document.url, type: .unknown)
        }
        self.init(
            displayName: fragment.displayName,
            displayNameLong: fragment.displayNameLong,
            quoteId: fragment.quoteId,
            addonId: fragment.addonId,
            addonSubtype: fragment.addonSubtype,
            displayItems: displayItems,
            itemCost: .init(fragment: fragment.itemCost.fragments.itemCostFragment),
            addonVariant: .init(fragment: fragment.addonVariant.fragments.addonVariantFragment),
            documents: documents,
        )
    }
}

extension AddonDisplayItem {
    init(
        fragment: OctopusGraphQL.UpsellTravelAddonDisplayItemFragment
    ) {
        self.init(displayTitle: fragment.displayTitle, displayValue: fragment.displayValue)
    }
}

extension AddonSource {
    public var getSource: OctopusGraphQL.UpsellTravelAddonFlow {
        switch self {
        case .insurances, .crossSell: return .appOnlyUpsale
        case .travelCertificates, .deeplink: return .appUpsellUpgrade
        }
    }
}
