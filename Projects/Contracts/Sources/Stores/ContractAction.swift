import Apollo
import Flow
import Presentation
import SwiftUI
import TerminateContracts
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

public enum ContractDetailNavigationAction: ActionProtocol, Hashable {
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case document(url: URL, title: String)
    case openInsuranceUpdate(contract: Contract)
    case dismissUpcomingChanges
}

public enum ContractAction: ActionProtocol, Hashable {

    // fetch everything
    case fetch
    case fetchCompleted
    // Fetch contracts for terminated
    case fetchCrossSale
    case fetchContracts

    case setActiveContracts(contracts: [Contract])
    case setTerminatedContracts(contracts: [Contract])
    case setPendingContracts(contracts: [Contract])

    case setCrossSells(crossSells: [CrossSell])
    case goToMovingFlow
    case goToFreeTextChat
    case openCrossSellingWebUrl(url: URL)

    case hasSeenCrossSells(value: Bool)
    case closeCrossSellingSigned
    case openDetail(contractId: String, title: String)
    case openTerminatedContracts

    case contractDetailNavigationAction(action: ContractDetailNavigationAction)
    case dismisscontractDetailNavigation
    case contractEditInfo(id: String)
    case dismissEditInfo(type: EditType?)
    case startTermination(action: TerminationNavigationAction)
}

public enum ContractLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
}

public enum EditType: String, Codable, Hashable, CaseIterable {
    case changeAddress
    case coInsured

    var buttonTitle: String {
        switch self {
        case .changeAddress: return L10n.generalContinueButton
        case .coInsured: return L10n.openChat
        }
    }

    var title: String {
        switch self {
        case .coInsured: return L10n.contractEditCoinsured
        case .changeAddress: return L10n.InsuranceDetails.changeAddressButton
        }
    }

    public static func getTypes(for contract: Contract) -> [EditType] {
        var editTypes: [EditType] = []

        if hAnalyticsExperiment.movingFlow && contract.supportsAddressChange {
            editTypes.append(.changeAddress)
        }
        if contract.canChangeCoInsured {
            editTypes.append(.coInsured)
        }
        return editTypes
    }
}

extension Contract {
    public var showEditButton: Bool {
        return !EditType.getTypes(for: self).isEmpty && self.terminationDate == nil
    }
}
