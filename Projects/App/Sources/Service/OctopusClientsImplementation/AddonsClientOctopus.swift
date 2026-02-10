import Addons
import AutomaticLog
import Foundation
import hCore
import hGraphQL

class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    @Log
    public func getAddonOffer(contractId: String) async throws -> AddonOffer {
        let mutation = OctopusGraphQL.AddonGenerateOfferMutation(contractId: contractId)
        let response = try await octopus.client.mutation(mutation: mutation)

        guard let result = response?.addonGenerateOffer else {
            throw AddonsError.somethingWentWrong
        }

        if let userError = result.asUserError {
            throw AddonsError.errorMessage(message: userError.message!)
        }

        guard let addonOffer = result.asAddonOffer else {
            throw AddonsError.somethingWentWrong
        }

        let quote = AddonContractQuote(data: addonOffer.quote)
        let currentTotalCost = ItemCost(fragment: addonOffer.currentTotalCost.fragments.itemCostFragment)

        return AddonOffer(
            pageTitle: addonOffer.pageTitle,
            pageDescription: addonOffer.pageDescription,
            quote: quote,
            currentTotalCost: currentTotalCost,
            infoMessage: addonOffer.infoMessage
        )
    }

    @Log
    public func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
        let sumbitAddonsMutation = OctopusGraphQL.AddonActivateOfferMutation(
            quoteId: quoteId,
            addonIds: Array(addonIds)
        )

        let response = try await octopus.client.mutation(mutation: sumbitAddonsMutation)
        if let error = response?.addonActivateOffer.userError?.message {
            throw AddonsError.errorMessage(message: error)
        }
    }

    @Log
    func getAddonBanners(source: AddonSource) async throws -> [AddonBanner] {
        let query = OctopusGraphQL.AddonBannersQuery(flows: source.flows)

        let data = try await octopus.client.fetch(query: query)
        let banners = data.currentMember.addonBanners

        return banners.filter { !$0.contractIds.isEmpty }
            .map { banner in
                AddonBanner(
                    contractIds: banner.contractIds,
                    titleDisplayName: banner.displayTitleName,
                    descriptionDisplayName: banner.descriptionDisplayName,
                    badges: banner.badges
                )
            }
    }
}

extension AddonSource {
    public var flows: [GraphQLEnum<OctopusGraphQL.AddonFlow>] {
        let rawFlows: [OctopusGraphQL.AddonFlow] =
            switch self {
            case .insurances, .crossSell: [.appTravelPlusSellOnly, .appCarPlus]
            case .travelCertificates, .deeplink: [.appTravelPlusSellOrUpgrade]
            }
        return rawFlows.map(GraphQLEnum.init)
    }
}

// MARK: - AddonOffer Extensions

extension AddonContractQuote {
    @MainActor
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote) {
        self.init(
            quoteId: data.quoteId,
            displayTitle: data.displayTitle,
            displayDescription: data.displayDescription,
            activationDate: data.activationDate.localDateToDate ?? Date(),
            addonOffer: .init(data: data.addonOffer),
            activeAddons: data.activeAddons.map { .init(data: $0) },
            baseQuoteCost: ItemCost(fragment: data.baseQuoteCost.fragments.itemCostFragment),
            productVariant: ProductVariant(data: data.productVariant.fragments.productVariantFragment)
        )
    }
}

extension AddonOfferContent {
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer) {
        if let selectable = data.asAddonOfferSelectable {
            self = .selectable(.init(data: selectable))
        } else if let toggleable = data.asAddonOfferToggleable {
            self = .toggleable(.init(data: toggleable))
        } else {
            // Default to toggleable with empty quotes if neither type matches
            self = .toggleable(.init(quotes: []))
        }
    }
}

extension AddonOfferSelectable {
    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferSelectable
    ) {
        self.init(
            fieldTitle: data.fieldTitle,
            selectionTitle: data.selectionTitle,
            selectionDescription: data.selectionDescription,
            quotes: data.quotes.map { .init(fragment: $0.fragments.addonOfferQuoteFragment) }
        )
    }
}

extension AddonOfferToggleable {
    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable
    ) {
        self.init(quotes: data.quotes.map { .init(fragment: $0.fragments.addonOfferQuoteFragment) })
    }
}

extension AddonOfferQuote {
    init(fragment: OctopusGraphQL.AddonOfferQuoteFragment) {
        self.init(
            id: fragment.id,
            displayTitle: fragment.displayTitle,
            displayDescription: fragment.displayDescription,
            displayItems: fragment.displayItems.map { .init(fragment: $0) },
            cost: ItemCost(fragment: fragment.cost.fragments.itemCostFragment),
            addonVariant: AddonVariant(fragment: fragment.addonVariant.fragments.addonVariantFragment),
            subType: fragment.subtype
        )
    }
}

extension AddonDisplayItem {
    init(fragment: OctopusGraphQL.AddonOfferQuoteFragment.DisplayItem) {
        self.init(displayTitle: fragment.displayTitle, displayValue: fragment.displayValue)
    }
}

extension ActiveAddon {
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon) {
        self.init(
            id: data.id,
            cost: ItemCost(fragment: data.cost.fragments.itemCostFragment),
            displayTitle: data.displayTitle,
            displayDescription: data.displayDescription
        )
    }
}
