import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

public enum TerminationStepModelAction: ActionProtocol, Hashable {
    case setTerminationDateStep(model: TerminationFlowDateNextStepModel)
    case setTerminationDeletion(model: TerminationFlowDeletionNextModel)
    case setSuccessStep(model: TerminationFlowSuccessNextModel)
    case setFailedStep(model: TerminationFlowFailedNextModel)
}

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
    case upcomingAgreement(details: DetailAgreementsTable)
}

public enum CrossSellingFAQListNavigationAction: ActionProtocol, Hashable {
    case list
    case detail(faq: FAQ)
    case chat
}

public indirect enum ContractAction: ActionProtocol, Hashable {

    // fetch everything
    case fetch

    // Fetch contracts for terminated
    case fetchContractBundles
    case fetchCrossSale
    case fetchContracts

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
    case openDetail(contractId: String)
    case openTerminatedContracts
    case didSignFocusedCrossSell
    case resetSignedCrossSells

    case contractDetailNavigationAction(action: ContractDetailNavigationAction)

    case openSetTerminationDateScreen(contractId: String)
    case sendTermination(terminationDate: Date, surveyUrl: String)
    case dismissTerminationFlow

    case startTermination(contractId: String)
    case sendTerminationDate(terminationDate: Date)
    case deleteTermination

    case setLoadingState(action: ContractAction, state: LoadingState<String>?)
    case setTerminationContext(context: String)
    case setTerminationContractId(id: String)

    case stepModelAction(action: TerminationStepModelAction)
    case navigationAction(action: TerminationNavigationAction)
    case terminationInitialNavigation(action: TerminationNavigationAction)

    case navigationActionMovingFlow(action: MovingFlowNavigationAction)
    case getMoveIntent
    case setMoveIntent
    case setMovingDate(movingDate: Date)
}

public enum TerminationNavigationAction: ActionProtocol, Hashable {
    case openTerminationSuccessScreen
    case openTerminationSetDateScreen
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case openTerminationDeletionScreen
}

public enum MovingFlowNavigationAction: ActionProtocol, Hashable {
    case openHousingTypeScreen
    case openDatePickerScreen
    case openAddressFillScreen
    case openConfirmScreen
    case openFailureScreen
    case dismissMovingFlow
}
