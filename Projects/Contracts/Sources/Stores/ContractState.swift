import Addons
import Apollo
import EditCoInsured
import PresentableStore
import SwiftUI

public struct ContractState: StateProtocol {
    public init() {}

    public var activeContracts: [Contract] = []
    public var terminatedContracts: [Contract] = []
    public var pendingContracts: [Contract] = []

    public var allStakeHolders: [StakeHolder] {
        let stakeHolders = activeContracts.flatMap { contract in
            (contract.coInsured + contract.coOwners).filter { !$0.hasMissingData }
        }
        let unique = Set(stakeHolders)
        return unique.sorted(by: { $0.id > $1.id })
    }

    public func fetchAllStakeHoldersNotInContract(contractId: String) -> [StakeHolder] {
        guard let contract = contractForId(contractId) else { return [] }
        let contractStakeHolders = Set(contract.coInsured + contract.coOwners)
        let stakeHoldersNotAdded = allStakeHolders.filter { !contractStakeHolders.contains($0) }

        return stakeHoldersNotAdded
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
extension ContractStore: ExistingStakeHolders {
    public func get(contractId: String) -> [StakeHolder] {
        state.fetchAllStakeHoldersNotInContract(contractId: contractId)
    }
}

extension ContractStore {
    public func getAddonConfigsFor(contractIds ids: [String]) -> [AddonConfig] {
        let addonContracts = ids.compactMap {
            self.state.contractForId($0)
        }
        let addonContractsConfig: [AddonConfig] = addonContracts.map {
            .init(
                contractId: $0.id,
                exposureName: $0.exposureDisplayName,
                displayName: $0.currentAgreement?.productVariant.displayName ?? ""
            )
        }
        return addonContractsConfig
    }
}
