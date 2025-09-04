import Addons
import Contracts
import Foundation
import PresentableStore
import hCore
import hCoreUI
import hGraphQL

class FetchContractsClientOctopus: FetchContractsClient {
    @Inject private var octopus: hOctopus

    func getContracts() async throws -> ContractsStack {
        let query = OctopusGraphQL.ContractBundleQuery(
            options: .some(OctopusGraphQL.DisplayItemOptions(hidePrice: true))
        )
        let contracts = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

        let firstName = contracts.currentMember.firstName
        let lastName = contracts.currentMember.lastName
        let ssn = contracts.currentMember.ssn
        let activeContracts = contracts.currentMember.activeContracts.map { contract in
            var agreementCosts = [ItemCost.ItemCostDiscount]()
            agreementCosts.append(
                .init(
                    displayName: contract.currentAgreement.productVariant.displayName,
                    displayValue: MonetaryAmount(
                        fragment: contract.currentAgreement.basePremium.fragments.moneyFragment
                    )
                    .priceFormat(.perMonth)
                )
            )
            agreementCosts.append(
                contentsOf: contract.currentAgreement.addons.map { addon in
                    .init(
                        displayName: addon.addonVariant.displayName,
                        displayValue: MonetaryAmount(fragment: addon.premium.fragments.moneyFragment)
                            .priceFormat(.perMonth)
                    )
                }
            )

            let currentAgreement = Agreement(
                agreement: contract.currentAgreement.fragments.agreementFragment,
                itemCost: .init(
                    itemCostDiscounts: agreementCosts,
                    fragment: contract.currentAgreement.cost.fragments.itemCostFragment
                ),
                displayItems: contract.currentAgreement.displayItems.map {
                    .init(data: $0.fragments.agreementDisplayItemFragment)
                }
            )
            let upcomingAgreement: Agreement? = {
                if let upcomingAgreement = contract.upcomingChangedAgreement {
                    return .init(
                        agreement: upcomingAgreement.fragments.agreementFragment,
                        itemCost: .init(
                            itemCostDiscounts: [],
                            fragment: upcomingAgreement.cost.fragments.itemCostFragment
                        ),
                        displayItems: upcomingAgreement.displayItems.map {
                            .init(data: $0.fragments.agreementDisplayItemFragment)
                        }
                    )
                }
                return nil
            }()
            return Contract(
                contract: contract.fragments.contractFragment,
                currentAgreement: currentAgreement,
                upcomoingAgreement: upcomingAgreement,
                firstName: firstName,
                lastName: lastName,
                ssn: ssn
            )
        }

        let terminatedContracts = contracts.currentMember.terminatedContracts.map { contract in
            let currentAgreement = Agreement(
                agreement: contract.currentAgreement.fragments.agreementFragment,
                itemCost: nil,
                displayItems: contract.currentAgreement.displayItems.map {
                    .init(data: $0.fragments.agreementDisplayItemFragment)
                }
            )
            return Contract(
                contract: contract.fragments.contractFragment,
                currentAgreement: currentAgreement,
                upcomoingAgreement: nil,
                firstName: firstName,
                lastName: lastName,
                ssn: ssn
            )
        }

        let pendingContracts = contracts.currentMember.pendingContracts.map { contract in
            Contract(
                pendingContract: contract,
                firstName: firstName,
                lastName: lastName,
                ssn: ssn
            )
        }
        return .init(
            activeContracts: activeContracts,
            pendingContracts: pendingContracts,
            terminatedContracts: terminatedContracts
        )
    }

    func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
        let query = OctopusGraphQL.UpsellTravelAddonBannerQuery(flow: .case(source.getSource))
        let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        let bannerData = data.currentMember.upsellTravelAddonBanner

        if let bannerData, !bannerData.contractIds.isEmpty {
            return AddonBannerModel(
                contractIds: bannerData.contractIds,
                titleDisplayName: bannerData.titleDisplayName,
                descriptionDisplayName: bannerData.descriptionDisplayName,
                badges: bannerData.badges
            )
        } else {
            throw AddonsError.missingContracts
        }
    }
}

@MainActor
extension Contract {
    init(
        pendingContract: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.PendingContract,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        var agreementCosts = [ItemCost.ItemCostDiscount]()
        agreementCosts.append(
            .init(
                displayName: pendingContract.productVariant.displayName,
                displayValue: MonetaryAmount(fragment: pendingContract.basePremium.fragments.moneyFragment)
                    .priceFormat(.perMonth)
            )
        )
        agreementCosts.append(
            contentsOf: pendingContract.addons.map { addon in
                .init(
                    displayName: addon.addonVariant.displayName,
                    displayValue: MonetaryAmount(fragment: addon.premium.fragments.moneyFragment).priceFormat(.perMonth)
                )
            }
        )
        let currentAgreement = Agreement(
            premium: .init(fragment: pendingContract.premium.fragments.moneyFragment),
            basePremium: .init(fragment: pendingContract.basePremium.fragments.moneyFragment),
            itemCost: .init(
                itemCostDiscounts: agreementCosts,
                fragment: pendingContract.cost.fragments.itemCostFragment
            ),
            displayItems: pendingContract.displayItems.map { .init(data: $0.fragments.agreementDisplayItemFragment) },
            productVariant: .init(data: pendingContract.productVariant.fragments.productVariantFragment),
            addonVariant: pendingContract.addons.map { .init(fragment: $0.addonVariant.fragments.addonVariantFragment) }
        )
        self.init(
            id: pendingContract.id,
            currentAgreement: currentAgreement,
            exposureDisplayName: pendingContract.exposureDisplayName,
            masterInceptionDate: nil,
            terminationDate: nil,
            supportsAddressChange: false,
            supportsCoInsured: false,
            supportsTravelCertificate: false,
            supportsChangeTier: false,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: firstName,
            lastName: lastName,
            ssn: ssn,
            typeOfContract: TypeOfContract.resolve(for: pendingContract.productVariant.typeOfContract),
            coInsured: []
        )
    }

    init(
        contract: OctopusGraphQL.ContractFragment,
        currentAgreement: Agreement?,
        upcomoingAgreement: Agreement?,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.init(
            id: contract.id,
            currentAgreement: currentAgreement,
            exposureDisplayName: contract.exposureDisplayName,
            masterInceptionDate: contract.masterInceptionDate,
            terminationDate: contract.terminationDate,
            supportsAddressChange: contract.supportsMoving,
            supportsCoInsured: contract.supportsCoInsured,
            supportsTravelCertificate: contract.supportsTravelCertificate,
            supportsChangeTier: contract.supportsChangeTier,
            upcomingChangedAgreement: upcomoingAgreement,
            upcomingRenewal: .init(upcoming: contract.upcomingChangedAgreement?.fragments.agreementFragment),
            firstName: firstName,
            lastName: lastName,
            ssn: ssn,
            typeOfContract: TypeOfContract.resolve(for: contract.currentAgreement.productVariant.typeOfContract),
            coInsured: contract.coInsured?.map { .init(data: $0.fragments.coInsuredFragment) } ?? []
        )
    }
}

extension Agreement {
    init?(
        agreement: OctopusGraphQL.AgreementFragment?,
        itemCost: ItemCost?,
        displayItems: [AgreementDisplayItem]
    ) {
        guard let agreement = agreement else {
            return nil
        }
        self.init(
            certificateUrl: agreement.certificateUrl,
            activeFrom: agreement.activeFrom,
            activeTo: agreement.activeTo,
            premium: .init(fragment: agreement.premium.fragments.moneyFragment),
            basePremium: .init(fragment: agreement.basePremium.fragments.moneyFragment),
            itemCost: itemCost,
            displayItems: displayItems,
            productVariant: .init(data: agreement.productVariant.fragments.productVariantFragment),
            addonVariant: agreement.addons.map { .init(fragment: $0.addonVariant.fragments.addonVariantFragment) }
        )
    }
}

extension ContractRenewal {
    init?(upcoming: OctopusGraphQL.AgreementFragment?) {
        guard let upcoming = upcoming, upcoming.creationCause == .renewal else { return nil }
        self.init(
            renewalDate: upcoming.activeFrom,
            certificateUrl: upcoming.certificateUrl
        )
    }
}

extension AgreementDisplayItem {
    public init(
        data: OctopusGraphQL.AgreementDisplayItemFragment
    ) {
        self.init(
            title: data.displayTitle,
            value: data.displayValue
        )
    }
}

extension ItemCost {
    public init?(
        itemCostDiscounts: [ItemCost.ItemCostDiscount],
        fragment: OctopusGraphQL.ItemCostFragment?
    ) {
        guard let fragment else {
            return nil
        }
        var discounts = [ItemCost.ItemCostDiscount]()
        discounts.append(contentsOf: itemCostDiscounts)
        discounts.append(
            contentsOf: fragment.discounts.map { discount in
                .init(displayName: discount.displayName, displayValue: discount.displayValue)
            }
        )
        self.init(
            gross: .init(fragment: fragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: fragment.monthlyNet.fragments.moneyFragment),
            discounts: discounts
        )
    }
}
