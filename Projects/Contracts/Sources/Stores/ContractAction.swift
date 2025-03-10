import Apollo
import EditCoInsuredShared
import PresentableStore
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

public enum ContractAction: ActionProtocol, Hashable {
    // Fetch contracts for terminated
    case fetchContracts

    case setActiveContracts(contracts: [Contract])
    case setTerminatedContracts(contracts: [Contract])
    case setPendingContracts(contracts: [Contract])
}

public enum ContractLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
    case postCoInsured
    case fetchNameFromSSN
}

@MainActor
extension EditType {
    public static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        if contract.supportsChangeTier {
            editTypes.append(.changeTier)
        }
        if Dependencies.featureFlags().isEditCoInsuredEnabled && contract.supportsCoInsured {
            editTypes.append(.coInsured)
        }

        if Dependencies.featureFlags().isTerminationFlowEnabled && contract.canTerminate {
            editTypes.append(.cancellation)
        }

        return editTypes
    }
}
