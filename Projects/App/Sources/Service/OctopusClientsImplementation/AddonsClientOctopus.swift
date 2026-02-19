import Addons
import Foundation
import hCore
import hGraphQL

class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public func getAddonOffer(contractId: String) async throws -> AddonOffer {
        let mutation = OctopusGraphQL.AddonGenerateOfferMutation(contractId: contractId)
        let response = try await octopus.client.mutation(mutation: mutation)

        guard let result = response?.addonGenerateOffer else {
            throw AddonsError.somethingWentWrong
        }

        if let errorMessage = result.asUserError?.message {
            throw AddonsError.errorMessage(message: errorMessage)
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
            infoMessage: addonOffer.infoMessage,
            whatsIncludedPageTitle: addonOffer.whatsIncludedPageTitle,
            whatsIncludedPageDescription: addonOffer.whatsIncludedPageDescription
        )
    }

    public func getAddonOfferCost(quoteId: String, addonIds: Set<String>) async throws -> ItemCost {
        let query = OctopusGraphQL.AddonOfferCostQuery(quoteId: quoteId, selectedAddonIds: Array(addonIds))
        let data = try await octopus.client.fetch(query: query)
        return .init(fragment: data.addonOfferCost.fragments.itemCostFragment)
    }

    public func getAddonRemoveOfferCost(contractId: String, addonIds: Set<String>) async throws -> ItemCost {
        let query = OctopusGraphQL.AddonRemoveOfferCostQuery(contractId: contractId, addonIds: Array(addonIds))
        let data = try await octopus.client.fetch(query: query)
        return .init(fragment: data.addonRemoveOfferCost.fragments.itemCostFragment)
    }

    public func submitAddons(quoteId: String, addonIds: Set<String>) async throws {
        let mutation = OctopusGraphQL.AddonActivateOfferMutation(quoteId: quoteId, selectedAddonIds: Array(addonIds))

        let response = try await octopus.client.mutation(mutation: mutation)
        if let error = response?.addonActivateOffer.userError?.message {
            throw AddonsError.errorMessage(message: error)
        }
    }

    public func getAddonRemoveOffer(contractId: String) async throws -> AddonRemoveOffer {
        let query = OctopusGraphQL.AddonRemoveStartQuery(contractId: contractId)
        let response = try await octopus.client.fetch(query: query)

        let result = response.addonRemoveStart

        if let userError = result.asUserError {
            throw AddonsError.errorMessage(message: userError.message!)
        }

        guard let offer = result.asAddonRemoveOffer else {
            throw AddonsError.somethingWentWrong
        }

        return AddonRemoveOffer(
            pageTitle: offer.pageTitle,
            pageDescription: offer.pageDescription,
            currentTotalCost: ItemCost(fragment: offer.currentTotalCost.fragments.itemCostFragment),
            baseCost: ItemCost(fragment: offer.baseCost.fragments.itemCostFragment),
            productVariant: ProductVariant(data: offer.productVariant.fragments.productVariantFragment),
            activationDate: offer.activationDate.localDateToDate ?? Date(),
            removableAddons: offer.removableAddons.map { .init(data: $0) }
        )
    }

    public func confirmAddonRemoval(contractId: String, addonIds: Set<String>) async throws {
        let mutation = OctopusGraphQL.AddonRemoveConfirmMutation(contractId: contractId, addonIds: Array(addonIds))
        let response = try await octopus.client.mutation(mutation: mutation)
        if let errorMessage = response?.addonRemoveConfirm?.message {
            throw AddonsError.errorMessage(message: errorMessage)
        }
    }

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
                    badges: banner.badges,
                    addonType: banner.flow.asAddonType
                )
            }
    }
}

extension GraphQLEnum<OctopusGraphQL.AddonFlow> {
    var asAddonType: AddonBanner.AddonType {
        switch self {
        case .case(let type):
            switch type {
            case .appCarPlus:
                return .carPlus
            case .appTravelPlusSellOnly:
                return .travelPlus
            case .appTravelPlusSellOrUpgrade:
                return .travelPlus
            }
        case .unknown:
            return .unknown
        }
    }
}

extension AddonSource {
    public var flows: [GraphQLEnum<OctopusGraphQL.AddonFlow>] {
        let rawFlows: [OctopusGraphQL.AddonFlow] =
            switch self {
            case .insurances, .crossSell: [.appTravelPlusSellOnly, .appCarPlus]
            case .travelCertificates: [.appTravelPlusSellOrUpgrade]
            case .deeplink: [.appTravelPlusSellOrUpgrade, .appCarPlus]
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

    init(data: OctopusGraphQL.AddonRemoveStartQuery.Data.AddonRemoveStart.AsAddonRemoveOffer.RemovableAddon) {
        self.init(
            id: data.id,
            cost: ItemCost(fragment: data.cost.fragments.itemCostFragment),
            displayTitle: data.displayTitle,
            displayDescription: data.displayDescription
        )
    }
}
