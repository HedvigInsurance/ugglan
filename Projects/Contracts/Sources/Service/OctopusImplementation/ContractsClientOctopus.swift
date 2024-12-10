import Addons
import Foundation
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

    public func getCrossSell() async throws -> [CrossSell] {
        let query = OctopusGraphQL.CrossSellsQuery()
        let crossSells = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
        return crossSells.currentMember.fragments.crossSellFragment.crossSells.compactMap({
            CrossSell($0)
        })
    }

    public func getAddonBannerModel() async throws -> AddonBannerModel? {
        return .init(
            contractIds: ["69dae7d6-b859-4818-9c07-c4db470c60fa", "eda450de-0b89-4965-a018-552e7a078cf3"],
            titleDisplayName: "Travel Plus",
            descriptionDisplayName:
                "Extended travel insurance with extra coverage for your travels",
            badges: ["Popular"]
        )
    }
}
