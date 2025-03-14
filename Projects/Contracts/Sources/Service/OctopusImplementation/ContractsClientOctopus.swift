import Addons
import Foundation
import PresentableStore
import hCore
import hGraphQL

public class FetchContractsClientOctopus: FetchContractsClient {
    @Inject private var octopus: hOctopus
    public init() {}
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
