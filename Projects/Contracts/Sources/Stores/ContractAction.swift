import Apollo
import EditCoInsuredShared
import PresentableStore
import SwiftUI
import TerminateContracts
import hCore
import hCoreUI
import hGraphQL

public enum ContractAction: ActionProtocol, Hashable {

    // fetch everything
    case fetch
    // Fetch contracts for terminated
    case fetchCrossSale
    case fetchContracts

    case setActiveContracts(contracts: [Contract])
    case setTerminatedContracts(contracts: [Contract])
    case setPendingContracts(contracts: [Contract])

    case setCrossSells(crossSells: [CrossSell])
    case hasSeenCrossSells(value: Bool)
}

public enum ContractLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
    case postCoInsured
    case fetchNameFromSSN
    case fetchCrossSell
}

@MainActor
extension EditType {
    public static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        let contractStore: ContractStore = globalPresentableStoreContainer.get()
        let contractsThatSupportsMoving = contractStore.state.activeContracts.filter({ $0.supportsAddressChange })
        if Dependencies.featureFlags().isMovingFlowEnabled && contract.supportsAddressChange
            && contractsThatSupportsMoving.count < 2
        {
            editTypes.append(.changeAddress)
        }
        if contract.supportsChangeTier {
            editTypes.append(.changeTier)
        }
        if Dependencies.featureFlags().isEditCoInsuredEnabled && contract.supportsCoInsured {
            editTypes.append(.coInsured)
        }
        return editTypes
    }
}
