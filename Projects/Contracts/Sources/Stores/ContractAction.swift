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

public enum EditType: String, Codable, Hashable, CaseIterable {
    case changeAddress
    case coInsured

    var title: String {
        switch self {
        case .coInsured: return L10n.contractEditCoinsured
        case .changeAddress: return L10n.InsuranceDetails.changeAddressButton
        }
    }

    var buttonTitle: String {
        switch self {
        case .changeAddress: return L10n.generalContinueButton
        case .coInsured:
            if Dependencies.featureFlags().isEditCoInsuredEnabled {
                return L10n.generalContinueButton
            }
            return L10n.openChat
        }
    }

    public static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        if Dependencies.featureFlags().isMovingFlowEnabled && contract.supportsAddressChange {
            editTypes.append(.changeAddress)
        }
        if contract.supportsCoInsured {
            editTypes.append(.coInsured)
        }
        return editTypes
    }
}
