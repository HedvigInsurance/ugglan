import Apollo
import Flow
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hGraphQL

public struct ContractState: StateProtocol {
    
    public init() {}
    
    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    public var activeContracts: [Contract] = []
    public var terminatedContracts: [Contract] = []
    public var pendingContracts: [PendingContract] = []
    public var crossSells: [CrossSell] = []
    var currentTerminationContext: String?
    var terminationContractId: String? = ""
    
    func contractForId(_ id: String) -> Contract? {
        /** TODO ADD PENDING CONTRACTS */
        if let inBundleContract = activeContracts.compactMap({ $0 })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return
        activeContracts
            .first { contract in
                contract.id == id
            }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        crossSells.contains(where: { crossSell in !crossSell.hasBeenSeen })
    }
    
    public var hasActiveContracts: Bool {
        !(activeContracts.compactMap { $0 }.isEmpty)
    }
    
    public var isTravelInsuranceIncluded: Bool {
        return activeContracts.compactMap({ $0 }).contains(where: { $0.hasTravelInsurance })
        && hAnalyticsExperiment.travelInsurance
    }
}
