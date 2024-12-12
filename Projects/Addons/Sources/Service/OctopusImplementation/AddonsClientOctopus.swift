import Foundation
import hCore
import hGraphQL

@MainActor
public class AddonsService {
    @Inject var service: AddonsClient

    public func getAddon(contractId: String, source: AddonSource) async throws -> AddonOffer {
        log.info("AddonsService: getAddon", error: nil, attributes: nil)
        return try await service.getAddon(contractId: contractId, source: source)
    }

    public func submitAddon(quoteId: String, addonId: String) async throws {
        log.info("AddonsService: submitAddon", error: nil, attributes: nil)
        return try await service.submitAddon(quoteId: quoteId, addonId: addonId)
    }
}

public class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getAddon(contractId: String, source: AddonSource) async throws -> AddonOffer {
        do {
            let source: OctopusGraphQL.UpsellTravelAddonFlow = {
                switch source {
                case .appUpsell: return .appUpsell
                case .appUpgrade: return .appUpgrade
                }
            }()

            let mutation = OctopusGraphQL.UpsellTravelAddonOfferMutation(contractId: contractId, flow: .case(source))
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

    public func submitAddon(quoteId: String, addonId: String) async throws {
        do {
            let mutation = OctopusGraphQL.UpsellTravelAddonActivateMutation(quoteId: quoteId, addonId: addonId)
            let response = try await octopus.client.perform(mutation: mutation)

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
