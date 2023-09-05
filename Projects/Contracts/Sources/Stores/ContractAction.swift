import Apollo
import Flow
import Presentation
import SwiftUI
import TerminateContracts
import hCore
import hGraphQL

public enum CrossSellingCoverageDetailNavigationAction: ActionProtocol, Hashable {
    case detail(info: CrossSellInfo)
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case insuranceTerm(insuranceTerm: InsuranceTerm)
}

public enum ContractDetailNavigationAction: ActionProtocol, Hashable {
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case document(url: URL, title: String)
    case openInsuranceUpdate(contract: Contract)
    case dismissUpcomingChanges
}

public enum CrossSellingFAQListNavigationAction: ActionProtocol, Hashable {
    case list
    case detail(faq: FAQ)
    case chat
}

public enum ContractAction: ActionProtocol, Hashable {

    // fetch everything
    case fetch

    // Fetch contracts for terminated
    case fetchContractBundles
    case fetchContractBundlesDone
    case fetchCrossSale
    case fetchContracts
    case fetchContractsDone

    case setContractBundles(activeContractBundles: [ActiveContractBundle])
    case setCrossSells(crossSells: [CrossSell])
    case setContracts(contracts: [Contract])
    case goToMovingFlow
    case goToFreeTextChat
    case setFocusedCrossSell(focusedCrossSell: CrossSell?)
    case openCrossSellingEmbark(name: String)
    case openCrossSellingWebUrl(url: URL)
    case openCrossSellingChat

    case crossSellingDetailEmbark(name: String)
    case crossSellWebAction(url: URL)
    case crossSellingCoverageDetailNavigation(action: CrossSellingCoverageDetailNavigationAction)
    case crossSellingFAQListNavigation(action: CrossSellingFAQListNavigationAction)
    case openCrossSellingDetail(crossSell: CrossSell)
    case hasSeenCrossSells(value: Bool)
    case closeCrossSellingSigned
    case openDetail(contractId: String, title: String)
    case openTerminatedContracts
    case didSignFocusedCrossSell
    case resetSignedCrossSells

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
        var editTypes: [EditType] = [.changeAddress]
        if contract.canChangeCoInsured {
            editTypes.append(.coInsured)
        }
        return editTypes
    }
}
