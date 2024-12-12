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
        do {
            let mutation = OctopusGraphQL.UpsellTravelAddonOfferMutation(contractId: contractId)
            let data = try await octopus.client.perform(mutation: mutation)
            let response = data.upsellTravelAddonOffer

            if let error = response.userError, let message = error.message {
                throw AddonsError.errorMessage(message: message)
            }

            guard let addonOffer = response.offer else {
                throw AddonsError.somethingWentWrong
            }

            /* TODO: ADD CORRECT VALUES? */
            let currentAddon = AddonQuote(
                displayName: nil,
                quoteId: "quoteId",
                addonId: "addonId",
                displayItems: addonOffer.currentAddon?.displayItems
                    .map({ .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment) }) ?? [],
                price: .init(optionalFragment: addonOffer.currentAddon?.premium.fragments.moneyFragment),
                productVariant: .init(
                    termsVersion: "",
                    typeOfContract: "",
                    partner: nil,
                    perils: [],
                    insurableLimits: [],
                    documents: [],
                    displayName: "",
                    displayNameTier: nil,
                    tierDescription: nil
                )
            )

            let addonData = AddonOffer(
                titleDisplayName: addonOffer.titleDisplayName,
                description: addonOffer.descriptionDisplayName,
                activationDate: addonOffer.activationDate.localDateToDate,
                currentAddon: currentAddon,
                quotes: addonOffer.quotes.map({ .init(fragment: $0.fragments.upsellTravelAddonQuoteFragment) })
            )

            return addonData

        } catch let exception {
            if let exception = exception as? AddonsError {
                throw exception
            }
            throw AddonsError.somethingWentWrong
        }
    }

    public func submitAddon(quoteId: String, addonId: String) async throws -> Date? {
        /* TODO: Call mutation upsellTravelAddonActivate(quoteId: ID!, addonId: ID!) */
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return Date()
    }
}

extension AddonQuote {
    init(
        fragment: OctopusGraphQL.UpsellTravelAddonQuoteFragment
    ) {
        self.quoteId = fragment.quoteId
        self.addonId = fragment.addonId
        self.displayName = fragment.displayName
        self.displayItems = fragment.displayItems.map({
            .init(fragment: $0.fragments.upsellTravelAddonDisplayItemFragment)
        })
        self.price = .init(fragment: fragment.premium.fragments.moneyFragment)

        /* TODO: ADD CORRECT VALUES */
        self.productVariant = .init(
            termsVersion: "",
            typeOfContract: "",
            partner: nil,
            perils: [],
            insurableLimits: [],
            documents: [],
            displayName: "",
            displayNameTier: nil,
            tierDescription: nil
        )
    }
}

extension AddonDisplayItem {
    init(
        fragment: OctopusGraphQL.UpsellTravelAddonDisplayItemFragment
    ) {
        self.displayTitle = fragment.displayTitle
        self.displayValue = fragment.displayValue
    }
}
