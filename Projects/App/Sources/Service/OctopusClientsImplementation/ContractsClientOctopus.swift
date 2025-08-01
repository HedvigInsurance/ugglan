import Addons
import Contracts
import Foundation
import PresentableStore
import hCore
import hCoreUI
import hGraphQL

class FetchContractsClientOctopus: FetchContractsClient {
    @Inject private var octopus: hOctopus

    public func getContracts() async throws -> ContractsStack {
        let query = OctopusGraphQL.ContractBundleQuery()
        let contracts = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)

        let firstName = contracts.currentMember.firstName
        let lastName = contracts.currentMember.lastName
        let ssn = contracts.currentMember.ssn
        let activeContracts = contracts.currentMember.activeContracts.map { contract in
            Contract(
                contract: contract.fragments.contractFragment,
                firstName: firstName,
                lastName: lastName,
                ssn: ssn
            )
        }

        let terminatedContracts = contracts.currentMember.terminatedContracts.map { contract in
            Contract(
                contract: contract.fragments.contractFragment,
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

    public func getAddonBannerModel(source: AddonSource) async throws -> AddonBannerModel? {
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
        let currentAgreement = Agreement(
            premium: .init(fragment: pendingContract.premium.fragments.moneyFragment),
            displayItems: pendingContract.displayItems.map { .init(data: $0.fragments.agreementDisplayItemFragment) },
            productVariant: .init(data: pendingContract.productVariant.fragments.productVariantFragment),
            addonVariant: []
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
        firstName: String,
        lastName: String,
        ssn: String?
    ) {
        self.init(
            id: contract.id,
            currentAgreement: .init(agreement: contract.currentAgreement.fragments.agreementFragment),
            exposureDisplayName: contract.exposureDisplayName,
            masterInceptionDate: contract.masterInceptionDate,
            terminationDate: contract.terminationDate,
            supportsAddressChange: contract.supportsMoving,
            supportsCoInsured: contract.supportsCoInsured,
            supportsTravelCertificate: contract.supportsTravelCertificate,
            supportsChangeTier: contract.supportsChangeTier,
            upcomingChangedAgreement: .init(agreement: contract.upcomingChangedAgreement?.fragments.agreementFragment),
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
        agreement: OctopusGraphQL.AgreementFragment?
    ) {
        guard let agreement = agreement else {
            return nil
        }
        self.init(
            certificateUrl: agreement.certificateUrl,
            activeFrom: agreement.activeFrom,
            activeTo: agreement.activeTo,
            premium: .init(fragment: agreement.premium.fragments.moneyFragment),
            displayItems: agreement.displayItems.map { .init(data: $0.fragments.agreementDisplayItemFragment) },
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
