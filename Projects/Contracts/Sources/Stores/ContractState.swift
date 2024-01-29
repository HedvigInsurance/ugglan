import Apollo
import EditCoInsured
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public struct ContractState: StateProtocol {

    public init() {}

    public var activeContracts: [Contract] = []
    public var terminatedContracts: [Contract] = []
    public var pendingContracts: [Contract] = []
    public var crossSells: [CrossSell] = []

    public var fetchAllCoInsured: [CoInsuredModel] {
        let coInsuredList = activeContracts.flatMap { coInsured in
            coInsured.coInsured.filter({ !$0.hasMissingData })
        }
        let unique = Set(coInsuredList)
        return unique.sorted(by: { $0.id > $1.id })
    }

    public func fetchAllCoInsuredNotInContract(contractId: String) -> [CoInsuredModel] {
        let contractCoInsured = contractForId(contractId)?.coInsured
        let coInsuredNotAdded = fetchAllCoInsured.compactMap {
            if !(contractCoInsured?.contains($0) ?? false) {
                return $0
            } else {
                return nil
            }
        }

        return coInsuredNotAdded
    }

    public func contractForId(_ id: String) -> Contract? {
        let activeContracts = activeContracts.compactMap({ $0 })
        let terminatedContracts = terminatedContracts.compactMap({ $0 })
        let pendingContracts = pendingContracts.compactMap({ $0 })
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
    public var hasUnseenCrossSell: Bool {
        crossSells.contains(where: { crossSell in !crossSell.hasBeenSeen })
    }

    public var hasActiveContracts: Bool {
        !(activeContracts.compactMap { $0 }.isEmpty)
    }
}
