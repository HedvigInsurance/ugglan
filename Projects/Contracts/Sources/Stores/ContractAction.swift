import Apollo
import EditCoInsured
import hCore
import hCoreUI
import PresentableStore
import SwiftUI
import TerminateContracts

public enum ContractAction: ActionProtocol, Hashable {
    // Fetch contracts for terminated
    case fetchContracts

    case setActiveContracts(contracts: [Contract])
    case setTerminatedContracts(contracts: [Contract])
    case setPendingContracts(contracts: [Contract])
}

public enum ContractLoadingAction: LoadingProtocol {
    case fetchContracts
}

@MainActor
public extension EditType {
    static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        if contract.supportsChangeTier {
            editTypes.append(.changeTier)
        }

        if contract.supportsCoInsured {
            editTypes.append(.coInsured)
        }

        if Dependencies.featureFlags().isTerminationFlowEnabled, contract.canTerminate {
            editTypes.append(.cancellation)
        }

        return editTypes
    }
}
