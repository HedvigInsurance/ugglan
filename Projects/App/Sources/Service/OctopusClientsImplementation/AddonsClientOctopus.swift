import Addons
import AutomaticLog
import Foundation
import hCore
import hGraphQL

class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    //    func getAddon(contractId: String) async throws -> AddonOffer {
    //        do {
    //            let mutation = OctopusGraphQL.UpsellTravelAddonOfferMutation(contractId: contractId)
    //
    //            let addonOfferData = try await octopus.client.mutation(mutation: mutation)
    //            let response = addonOfferData?.upsellTravelAddonOffer
    //
    //            if let error = response?.userError, let message = error.message {
    //                throw AddonsError.errorMessage(message: message)
    //            }
    //
    //            guard let addonOffer = response?.offer else {
    //                throw AddonsError.somethingWentWrong
    //            }
    //
    //            let currentAddon: AddonQuote? = {
    //                guard let currentAddon = addonOffer.currentAddon else { return nil }
    //
    //                return .init(
    //                    displayName: "",
    //                    displayNameLong: currentAddon.displayNameLong,
    //                    quoteId: "quoteId",
    //                    addonId: "addonId",
    //                    addonSubtype: "addonSubtype",
    //                    displayItems: currentAddon.displayItems.map {
    //                        .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment)
    //                    },
    //                    itemCost: .init(
    //                        premium: .init(
    //                            gross: nil,
    //                            net: .init(fragment: currentAddon.netPremium.fragments.moneyFragment)
    //                        ),
    //                        discounts: []
    //                    ),
    //                    addonVariant: nil,
    //                    documents: []
    //                )
    //            }()
    //            let addonData = AddonOffer(
    //                titleDisplayName: addonOffer.titleDisplayName,
    //                description: addonOffer.descriptionDisplayName,
    //                activationDate: addonOffer.activationDate.localDateToDate,
    //                currentAddon: currentAddon,
    //                quotes: addonOffer.quotes.map { quote in
    //                    .init(fragment: quote.fragments.upsellTravelAddonQuoteFragment)
    //                }
    //            )
    //
    //            return addonData
    //        } catch let exception {
    //            if let exception = exception as? AddonsError {
    //                throw exception
    //            }
    //            throw AddonsError.somethingWentWrong
    //        }
    //    }
    //
    //    func submitAddon(quoteId: String, addonId: String) async throws {
    //        do {
    //            let mutation = OctopusGraphQL.UpsellTravelAddonActivateMutation(quoteId: quoteId, addonId: addonId)
    //            let delayTask = Task {
    //                try await Task.sleep(seconds: 3)
    //            }
    //            let response = try await octopus.client.mutation(mutation: mutation)
    //            try await delayTask.value
    //            if let error = response?.upsellTravelAddonActivate.userError, let message = error.message {
    //                throw AddonsError.errorMessage(message: message)
    //            }
    //        } catch let exception {
    //            if let exception = exception as? AddonsError {
    //                throw exception
    //            }
    //            throw AddonsError.somethingWentWrong
    //        }
    //    }

    @Log
    public func getAddonV2(contractId: String) async throws -> AddonOfferV2 {
        let mutation = OctopusGraphQL.AddonGenerateOfferMutation(contractId: contractId)
        let response = try await octopus.client.mutation(mutation: mutation)

        guard let result = response?.addonGenerateOffer else {
            throw AddonsError.somethingWentWrong
        }

        // Handle UserError
        if let userError = result.asUserError {
            throw AddonsError.errorMessage(message: userError.message!)
        }

        // Map AddonOffer
        guard let addonOffer = result.asAddonOffer else {
            throw AddonsError.somethingWentWrong
        }

        return AddonOfferV2(
            pageTitle: addonOffer.pageTitle,
            pageDescription: addonOffer.pageDescription,
            quote: .init(data: addonOffer.quote),
            currentTotalCost: .init(data: addonOffer.currentTotalCost)
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
}

//extension AddonQuote {
//    init(
//        fragment: OctopusGraphQL.UpsellTravelAddonQuoteFragment
//    ) {
//        let displayItems: [AddonDisplayItem] = fragment.displayItems.map {
//            .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment)
//        }
//        let documents = fragment.documents.compactMap { document in
//            hPDFDocument(displayName: document.displayName, url: document.url, type: .unknown)
//        }
//        self.init(
//            displayName: fragment.displayName,
//            displayNameLong: fragment.displayNameLong,
//            quoteId: fragment.quoteId,
//            addonId: fragment.addonId,
//            addonSubtype: fragment.addonSubtype,
//            displayItems: displayItems,
//            itemCost: .init(fragment: fragment.itemCost.fragments.itemCostFragment),
//            addonVariant: .init(fragment: fragment.addonVariant.fragments.addonVariantFragment),
//            documents: documents,
//        )
//    }
//}

extension AddonDisplayItem {
    init(
        fragment: OctopusGraphQL.UpsellTravelAddonDisplayItemFragment
    ) {
        self.init(displayTitle: fragment.displayTitle, displayValue: fragment.displayValue)
    }

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
    public var getSource: OctopusGraphQL.UpsellTravelAddonFlow {
        switch self {
        case .insurances, .crossSell: return .appOnlyUpsale
        case .travelCertificates, .deeplink: return .appUpsellUpgrade
        }
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
            displayDescription: data.displayDescription
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
