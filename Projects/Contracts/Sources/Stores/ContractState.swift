import Addons
import Apollo
import EditStakeholders
import PresentableStore
import SwiftUI

public struct ContractState: StateProtocol {
    public init() {}

    public var activeContracts: [Contract] = []
    public var terminatedContracts: [Contract] = []
    public var pendingContracts: [Contract] = []

    public var allStakeholders: [Stakeholder] {
        let stakeholders = activeContracts.flatMap { contract in
            (contract.coInsured + contract.coOwners).filter { !$0.hasMissingData }
        }
        let unique = Set(stakeholders)
        return unique.sorted(by: { $0.id > $1.id })
    }

    public func fetchAllStakeholdersNotInContract(
        contractId: String,
        stakeholderType: StakeholderType,
    ) -> [Stakeholder] {
        guard let contract = contractForId(contractId) else { return [] }
        let contractStakeholders =
            switch stakeholderType {
            case .coInsured: Set(contract.coInsured)
            case .coOwner: Set(contract.coOwners)
            }

        let stakeholdersNotAdded = allStakeholders.filter { !contractStakeholders.contains($0) }

        return stakeholdersNotAdded
    }

    public func contractForId(_ id: String) -> Contract? {
        let activeContracts = activeContracts.compactMap { $0 }
        let terminatedContracts = terminatedContracts.compactMap { $0 }
        let pendingContracts = pendingContracts.compactMap { $0 }
        let allContracts = activeContracts + terminatedContracts + pendingContracts

        if let inBundleContract =
            allContracts
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return nil
    }
}

extension ContractState {
    public var hasActiveContracts: Bool {
        !(activeContracts.compactMap { $0 }.isEmpty)
    }
}

@MainActor
extension ContractStore: ExistingStakeholders {
    public func get(contractId: String, stakeholderType: StakeholderType) -> [Stakeholder] {
        state.fetchAllStakeholdersNotInContract(contractId: contractId, stakeholderType: stakeholderType)
    }
}

extension ContractStore {
    public func getAddonContractInfosFor(contractIds ids: [String]) -> [AddonContractInfo] {
        ids
            .compactMap { state.contractForId($0) }
            .map(\.asAddonContractInfo)
    }
}
