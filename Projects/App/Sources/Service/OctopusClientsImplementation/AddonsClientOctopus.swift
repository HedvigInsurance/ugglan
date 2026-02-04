import Addons
import AutomaticLog
import Foundation
import hCore
import hGraphQL

class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public func getAddonV2(contractId: String) async throws -> AddonOfferV2 {
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
        let currentTotalCost = ItemCost(data: addonOffer.currentTotalCost)

        let addonType: AddonType =
            switch (quote.selectableAddons.isEmpty, quote.toggleableAddons.isEmpty) {
            case (false, true): .travel
            case (true, false): .car
            default: throw AddonsError.somethingWentWrong
            }

        return AddonOfferV2(
            pageTitle: addonOffer.pageTitle,
            pageDescription: addonOffer.pageDescription,
            quote: quote,
            currentTotalCost: currentTotalCost,
            addonType: addonType
        )
    }

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

    func getAddonBanners(source: AddonSource) async throws -> [AddonBannerModel] {
        let query = OctopusGraphQL.AddonBannersQuery(flows: source.flows)

        let data = try await octopus.client.fetch(query: query)
        let banners = data.currentMember.addonBanners

        return banners.filter { !$0.contractIds.isEmpty }
            .map { banner in
                AddonBannerModel(
                    contractIds: banner.contractIds,
                    titleDisplayName: banner.displayTitleName,
                    descriptionDisplayName: banner.descriptionDisplayName,
                    badges: banner.badges
                )
            }
    }
}

extension AddonDisplayItem {
    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferSelectable.Quote.DisplayItem
    ) {
        self.init(displayTitle: data.displayTitle, displayValue: data.displayValue)
    }

    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable.Quote.DisplayItem
    ) {
        self.init(displayTitle: data.displayTitle, displayValue: data.displayValue)
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

// MARK: - AddonOfferV2 Extensions

extension ItemCost {
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.CurrentTotalCost) {
        self.init(fragment: data.fragments.itemCostFragment)
    }

    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.BaseQuoteCost) {
        self.init(
            premium: .init(
                gross: .init(
                    amount: String(data.monthlyGross.amount),
                    currency: data.monthlyGross.currencyCode.rawValue
                ),
                net: .init(amount: String(data.monthlyNet.amount), currency: data.monthlyNet.currencyCode.rawValue)
            ),
            discounts: data.discounts.map { discount in
                .init(
                    campaignCode: discount.campaignCode,
                    displayName: discount.displayName,
                    displayValue: discount.displayValue,
                    explanation: discount.explanation
                )
            }
        )
    }

    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon.Cost) {
        self.init(
            premium: .init(
                gross: .init(
                    amount: String(data.monthlyGross.amount),
                    currency: data.monthlyGross.currencyCode.rawValue
                ),
                net: .init(amount: String(data.monthlyNet.amount), currency: data.monthlyNet.currencyCode.rawValue)
            ),
            discounts: data.discounts.map { discount in
                .init(
                    campaignCode: discount.campaignCode,
                    displayName: discount.displayName,
                    displayValue: discount.displayValue,
                    explanation: discount.explanation
                )
            }
        )
    }

    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable.Quote.Cost
    ) {
        self.init(fragment: data.fragments.itemCostFragment)
    }
    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferSelectable.Quote.Cost
    ) {
        self.init(fragment: data.fragments.itemCostFragment)
    }
}

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
            baseQuoteCost: .init(data: data.baseQuoteCost),
            productVariant: .init(data: data.productVariant)
        )
    }
}

extension ProductVariant {
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant) {
        self.init(
            termsVersion: data.termsVersion,
            typeOfContract: data.typeOfContract,
            perils: data.perils.map { .init($0) },
            insurableLimits: data.insurableLimits.map { .init($0) },
            documents: data.documents.map { .init($0) },
            displayName: data.displayName,
            displayNameTier: data.displayNameTier,
            tierDescription: data.tierDescription
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
            quotes: data.quotes.map { .init(selectableData: $0) }
        )
    }
}

extension AddonOfferToggleable {
    init(
        data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable
    ) {
        self.init(quotes: data.quotes.map { .init(toggleableData: $0) })
    }
}

extension AddonOfferQuote {
    init(
        selectableData: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferSelectable.Quote
    ) {
        self.init(
            id: selectableData.id,
            displayTitle: selectableData.displayTitle,
            displayDescription: selectableData.displayDescription,
            displayItems: selectableData.displayItems.map { .init(data: $0) },
            cost: .init(data: selectableData.cost),
            addonVariant: .init(selectableData: selectableData.addonVariant)
        )
    }

    init(
        toggleableData: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable.Quote
    ) {
        self.init(
            id: toggleableData.id,
            displayTitle: toggleableData.displayTitle,
            displayDescription: toggleableData.displayDescription,
            displayItems: toggleableData.displayItems.map { .init(data: $0) },
            cost: .init(data: toggleableData.cost),
            addonVariant: .init(toggleableData: toggleableData.addonVariant)
        )
    }
}

extension AddonVariant {
    init(
        selectableData: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferSelectable.Quote.AddonVariant
    ) {
        self.init(
            displayName: selectableData.displayName,
            documents: [],
            perils: selectableData.addonPerils.map { peril in
                .init(
                    id: peril.title,
                    title: peril.title,
                    description: peril.description ?? "",
                    color: peril.colorCode,
                    covered: [],
                )
            },
            product: selectableData.product,
            termsVersion: selectableData.termsVersion
        )
    }

    init(
        toggleableData: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable.Quote.AddonVariant
    ) {
        self.init(
            displayName: toggleableData.displayName,
            documents: toggleableData.documents.map { .init($0) },
            perils: toggleableData.addonPerils.map { peril in
                .init(
                    id: peril.title,
                    title: peril.title,
                    description: peril.description ?? "",
                    color: peril.colorCode,
                    covered: [],
                )
            },
            product: toggleableData.product,
            termsVersion: toggleableData.termsVersion
        )
    }
}

extension ActiveAddon {
    init(data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ActiveAddon) {
        self.init(
            id: data.id,
            cost: .init(data: data.cost),
            displayTitle: data.displayTitle,
            displayDescription: data.displayDescription!
        )
    }
}

extension Perils {
    init(
        _ data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant
            .Peril
    ) {
        self.init(
            id: data.id,
            title: data.title,
            description: data.description,
            color: data.colorCode,
            covered: data.covered,
            isDisabled: false
        )
    }
}

extension InsurableLimits {
    init(
        _ data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant
            .InsurableLimit
    ) {
        self.init(
            label: data.label,
            limit: data.limit,
            description: data.description
        )
    }
}

extension hPDFDocument {
    init(
        _ data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.ProductVariant
            .Document
    ) {
        self.init(
            displayName: data.displayName,
            url: data.url,
            type: data.type.asTypeOfDocument
        )
    }

    init(
        _ data: OctopusGraphQL.AddonGenerateOfferMutation.Data.AddonGenerateOffer.AsAddonOffer.Quote.AddonOffer
            .AsAddonOfferToggleable.Quote.AddonVariant.Document
    ) {
        self.init(
            displayName: data.displayName,
            url: data.url,
            type: data.type.asTypeOfDocument
        )
    }
}
