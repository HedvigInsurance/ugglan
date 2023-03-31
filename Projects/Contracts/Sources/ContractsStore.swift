import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public struct ContractState: StateProtocol {

    public init() {}

    public var hasLoadedContractBundlesOnce = false
    public var contractBundles: [ActiveContractBundle] = []
    public var contracts: [Contract] = []
    public var focusedCrossSell: CrossSell?
    public var signedCrossSells: [CrossSell] = []
    public var terminations: TerminationStartFlow? = nil

    func contractForId(_ id: String) -> Contract? {
        if let inBundleContract = contractBundles.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return contracts.first { contract in
            contract.id == id
        }
    }
}

extension ContractState {
    public var hasUnseenCrossSell: Bool {
        contractBundles.contains(where: { bundle in bundle.crossSells.contains(where: { !$0.hasBeenSeen }) })
    }

    public var hasActiveContracts: Bool {
        !contractBundles.flatMap { $0.contracts }.isEmpty
    }
}

public enum CrossSellingCoverageDetailNavigationAction: ActionProtocol {
    case detail
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case insuranceTerm(insuranceTerm: InsuranceTerm)
}

public enum ContractDetailNavigationAction: ActionProtocol {
    case peril(peril: Perils)
    case insurableLimit(insurableLimit: InsurableLimits)
    case document(url: URL, title: String)
    case upcomingAgreement(details: DetailAgreementsTable)
}

public enum CrossSellingFAQListNavigationAction: ActionProtocol {
    case list
    case detail(faq: FAQ)
    case chat
}

public enum ContractAction: ActionProtocol {

    // fetch everything
    case fetch

    // Fetch contracts for terminated
    case fetchContractBundles
    case fetchContracts

    case setContractBundles(activeContractBundles: [ActiveContractBundle])
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

    case goToTerminationFlow(contractId: String, contextInput: String)
    case sendTermination(terminationDate: Date, contextInput: String, surveyUrl: String)
    case dismissTerminationFlow

    case startTermination(contractId: String)
    case sendTerminationDate(terminationDateInput: Date, contextInput: String)
    case setTerminationDetails(details: TerminationStartFlow)

    case openTerminationSuccess(terminationDateInput: Date, surveyURL: String)
    case openTerminationSetDateScreen(context: String)
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case submitTerminationDate(terminationDate: Date)
}

public final class ContractStore: StateStore<ContractState, ContractAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        switch action {
        case .fetchContractBundles:
            return giraffe.client
                .fetchActiveContractBundles(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .map { activeContractBundles in
                    ContractAction.setContractBundles(activeContractBundles: activeContractBundles)
                }
        case .fetchContracts:
            return giraffe.client.fetchContracts(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                .valueThenEndSignal
                .filter { contracts in
                    contracts != getState().contracts
                }
                .map {
                    .setContracts(contracts: $0)
                }
        case .fetch:
            return [
                .fetchContracts,
                .fetchContractBundles,
            ]
            .emitEachThenEnd
        case .didSignFocusedCrossSell:
            return [
                .fetch
            ]
            .emitEachThenEnd
        case let .openCrossSellingDetail(crossSell):
            return [
                .setFocusedCrossSell(focusedCrossSell: crossSell)
            ]
            .emitEachThenEnd

        case .startTermination(let contractId):

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowTerminationStartMutation(
                            input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId)
                        )
                    )
                    .onValue { data in
                        let step = data.flowTerminationStart.currentStep
                        let context = data.flowTerminationStart.context
                        var actions = [ContractAction]()

                        if let nextStep = step.asFlowTerminationDateStep {
                            actions.append(.goToTerminationFlow(contractId: contractId, contextInput: context))
                            actions.append(
                                .setTerminationDetails(
                                    details:
                                        TerminationStartFlow(
                                            id: nextStep.id,
                                            minDate: nextStep.minDate,
                                            maxDate: nextStep.maxDate
                                        )
                                )
                            )
                        } else if let nextStep = step.asFlowTerminationFailedStep {
                            actions.append(.openTerminationFailScreen)
                        } else if let nextStep = step.asFlowTerminationSuccessStep {
                            let terminationDate = nextStep.terminationDate
                            let surveyURL = nextStep.surveyUrl

                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            if let date = dateFormatter.date(from: terminationDate ?? "") {
                                actions.append(
                                    .openTerminationSuccess(terminationDateInput: date, surveyURL: surveyURL)
                                )
                            } else {
                                actions.append(.openTerminationFailScreen)
                            }
                        } else {
                            actions.append(.openTerminationUpdateAppScreen)
                        }
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in
                        log.error("Error: \(error)")
                    }
                return NilDisposer()
            }

        case .sendTerminationDate(let terminationDate, let contextInput):

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let inputDateToString = dateFormatter.string(from: terminationDate)
            let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowTerminationDateNextMutation(
                            input: terminationDateInput,
                            context: contextInput
                        )
                    )
                    .onValue { data in
                        let context = data.flowTerminationDateNext.context
                        var actions = [ContractAction]()
                        let step = data.flowTerminationDateNext.currentStep
                        if let nextStep = step.asFlowTerminationSuccessStep {
                            let surveyURL = nextStep.surveyUrl
                            actions.append(
                                .openTerminationSuccess(terminationDateInput: terminationDate, surveyURL: surveyURL)
                            )
                        } else if let nextStep = step.asFlowTerminationFailedStep {
                            actions.append(.openTerminationFailScreen)
                        } else if let nextStep = step.asFlowTerminationDateStep {
                            actions.append(.openTerminationSetDateScreen(context: context))
                        } else {
                            actions.append(.openTerminationUpdateAppScreen)
                        }
                        actions.forEach({ callback(.value($0)) })
                    }
                    .onError { error in
                        log.error("Error: \(error)")
                    }
                return NilDisposer()
            }

        default:
            break
        }
        return nil
    }

    public override func reduce(_ state: ContractState, _ action: ContractAction) -> ContractState {
        var newState = state
        switch action {
        case .setContractBundles(let activeContractBundles):
            newState.hasLoadedContractBundlesOnce = true
            // Prevent infinite spinner if there are no active contracts
            guard activeContractBundles != state.contractBundles else { return newState }

            newState.contractBundles = activeContractBundles
        case .setContracts(let contracts):
            newState.contracts = contracts
        case let .hasSeenCrossSells(value):
            newState.contractBundles = newState.contractBundles.map { bundle in
                var newBundle = bundle

                newBundle.crossSells = newBundle.crossSells.map { crossSell in
                    var newCrossSell = crossSell
                    newCrossSell.hasBeenSeen = value
                    return newCrossSell
                }

                return newBundle
            }
        case let .setFocusedCrossSell(focusedCrossSell):
            newState.focusedCrossSell = focusedCrossSell
        case .didSignFocusedCrossSell:
            newState.focusedCrossSell = nil
            newState.signedCrossSells = [newState.signedCrossSells, [newState.focusedCrossSell].compactMap { $0 }]
                .flatMap { $0 }
        case .resetSignedCrossSells:
            newState.signedCrossSells = []

        case .setTerminationDetails(let terminationDetails):
            newState.terminations = terminationDetails

        default:
            break
        }

        return newState
    }
}
