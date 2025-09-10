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
        let contractsData = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return .init(
            activeContracts: handleActiveContracts(data: contractsData),
            pendingContracts: handlePendingContracts(data: contractsData),
            terminatedContracts: handleTerminatedContracts(data: contractsData)
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

    private func getCost(
        productVariantFragment: OctopusGraphQL.ProductVariantFragment,
        basePremium: OctopusGraphQL.MoneyFragment,
        costFragment: OctopusGraphQL.ItemCostFragment,
        addonCostDiscounts: [ItemCost.ItemCostDiscount]
    ) -> ItemCost {
        var discounts = [ItemCost.ItemCostDiscount]()

        //add insurance disocunt
        discounts.append(
            .init(
                displayName: productVariantFragment.displayName,
                displayValue: MonetaryAmount(
                    fragment: basePremium
                )
                .priceFormat(.perMonth)
            )
        )

        //add additional discounts eg for addons
        discounts.append(
            contentsOf: addonCostDiscounts
        )

        //add cost fragment discounts
        discounts.append(
            contentsOf: costFragment.discounts.map { .init(displayName: $0.displayName, displayValue: $0.displayValue) }
        )

        return .init(
            gross: .init(fragment: costFragment.monthlyGross.fragments.moneyFragment),
            net: .init(fragment: costFragment.monthlyNet.fragments.moneyFragment),
            discounts: discounts
        )
    }

    private func getAddonDiscount(
        addonVariant: OctopusGraphQL.AddonVariantFragment,
        amount: OctopusGraphQL.MoneyFragment
    ) -> ItemCost.ItemCostDiscount {
        .init(
            displayName: addonVariant.displayName,
            displayValue: MonetaryAmount(fragment: amount)
                .priceFormat(.perMonth)
        )
    }
}

@MainActor
extension Contract {
    init(
        pendingContract: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.PendingContract,
        itemCost: ItemCost,
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        let currentAgreement = Agreement(
            basePremium: .init(fragment: pendingContract.basePremium.fragments.moneyFragment),
            itemCost: itemCost,
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

//MARK: Active contracts
extension FetchContractsClientOctopus {
    private func handleActiveContracts(data: OctopusGraphQL.ContractBundleQuery.Data) -> [Contract] {
        data.currentMember.activeContracts.map { contract in
            let currentAgreementAddonsDiscount = contract.currentAgreement.addons.map {
                getAddonDiscount(
                    addonVariant: $0.addonVariant.fragments.addonVariantFragment,
                    amount: $0.premium.fragments.moneyFragment
                )
            }

            let currentAgreement = Agreement(
                agreement: contract.currentAgreement.fragments.agreementFragment,
                itemCost: getCost(
                    productVariantFragment: contract.currentAgreement.productVariant.fragments.productVariantFragment,
                    basePremium: contract.currentAgreement.fragments.agreementFragment.basePremium.fragments
                        .moneyFragment,
                    costFragment: contract.currentAgreement.cost.fragments.itemCostFragment,
                    addonCostDiscounts: currentAgreementAddonsDiscount
                ),
                displayItems: contract.currentAgreement.displayItems.map(makeDisplayItem)
            )
            let upcomingAgreement: Agreement? = {
                if let upcomingAgreement = contract.upcomingChangedAgreement {
                    let upcomingAgreementAddonsDiscount = upcomingAgreement.addons.map {
                        getAddonDiscount(
                            addonVariant: $0.addonVariant.fragments.addonVariantFragment,
                            amount: $0.premium.fragments.moneyFragment
                        )
                    }
                    return .init(
                        agreement: upcomingAgreement.fragments.agreementFragment,
                        itemCost: getCost(
                            productVariantFragment: upcomingAgreement.productVariant.fragments.productVariantFragment,
                            basePremium: upcomingAgreement.basePremium.fragments.moneyFragment,
                            costFragment: upcomingAgreement.cost.fragments.itemCostFragment,
                            addonCostDiscounts: upcomingAgreementAddonsDiscount
                        ),
                        displayItems: upcomingAgreement.displayItems.map(makeDisplayItem)
                    )
                }
                return nil
            }()
            return Contract(
                contract: contract.fragments.contractFragment,
                currentAgreement: currentAgreement,
                upcomoingAgreement: upcomingAgreement,
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }

    private func makeDisplayItem(
        from item: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.ActiveContract.CurrentAgreement.DisplayItem
    ) -> AgreementDisplayItem {
        .init(data: item.fragments.agreementDisplayItemFragment)
    }

    private func makeDisplayItem(
        from item: OctopusGraphQL.ContractBundleQuery.Data.CurrentMember.ActiveContract.UpcomingChangedAgreement
            .DisplayItem
    ) -> AgreementDisplayItem {
        .init(data: item.fragments.agreementDisplayItemFragment)
    }
}

//MARK: Terminated contracts
extension FetchContractsClientOctopus {
    private func handleTerminatedContracts(data: OctopusGraphQL.ContractBundleQuery.Data) -> [Contract] {
        data.currentMember.terminatedContracts.map { contract in
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
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }
}

//MARK: Pending contracts
extension FetchContractsClientOctopus {
    private func handlePendingContracts(data: OctopusGraphQL.ContractBundleQuery.Data) -> [Contract] {
        data.currentMember.pendingContracts.map { contract in
            let addonsDiscount = contract.addons.map { addon in
                getAddonDiscount(
                    addonVariant: addon.addonVariant.fragments.addonVariantFragment,
                    amount: addon.premium.fragments.moneyFragment
                )
            }
            return Contract(
                pendingContract: contract,
                itemCost: getCost(
                    productVariantFragment: contract.productVariant.fragments.productVariantFragment,
                    basePremium: contract.basePremium.fragments.moneyFragment,
                    costFragment: contract.cost.fragments.itemCostFragment,
                    addonCostDiscounts: addonsDiscount
                ),
                firstName: data.currentMember.firstName,
                lastName: data.currentMember.lastName,
                ssn: data.currentMember.ssn
            )
        }
    }
}
