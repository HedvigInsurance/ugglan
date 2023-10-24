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
    public var pendingContracts: [Contract] = []
    public var crossSells: [CrossSell] = []
    var currentTerminationContext: String?
    var coInsured: [CoInsuredModel] = [CoInsuredModel(name: "Tove Forsman", SSN: "111111-1111", type: nil)]
    var localCoInsured: [CoInsuredModel] = []
    var haveChangedCoInsured: Bool = false

    func contractForId(_ id: String) -> Contract? {
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

    public var isTravelInsuranceIncluded: Bool {
        return activeContracts.compactMap({ $0 }).contains(where: { $0.hasTravelInsurance })
            && hAnalyticsExperiment.travelInsurance
    }
}
