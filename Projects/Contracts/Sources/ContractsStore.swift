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
    public var terminations: TerminationStartFlow = TerminationStartFlow(id: "", context: "")

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

    case goToTerminationFlow(contractId: String)
    case sendTermination(terminationDate: Date, surveyUrl: String)
    case dismissTerminationFlow

    case startTermination(contractId: String)
    case sendTerminationDate(terminationDate: Date)
    case setTerminationDetails(id: String, minDate: String, maxDate: String?)
    case setDisclaimer(disclaimer: String)
    case setContext(context: String)
    case setSurveyURL(surveyURL: String)
    case setTerminationDate(date: Date)
    case deleteTermination

    case openTerminationSuccess
    case openTerminationSetDateScreen(context: String)
    case openTerminationUpdateAppScreen
    case openTerminationFailScreen
    case openTerminationDeletionScreen
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
                        actions.append(.setContext(context: context))

                        if let nextStep = step.asFlowTerminationDateStep {
                            actions.append(
                                .setTerminationDetails(
                                    id: nextStep.id,
                                    minDate: nextStep.minDate,
                                    maxDate: nextStep.maxDate
                                )
                            )
                            actions.append(.goToTerminationFlow(contractId: contractId))
                        } else if let nextStep = step.asFlowTerminationFailedStep {
                            actions.append(.openTerminationFailScreen)
                        } else if let nextStep = step.asFlowTerminationSuccessStep {
                            let terminationDate = nextStep.terminationDate
                            let surveyURL = nextStep.surveyUrl
                            actions.append(.setSurveyURL(surveyURL: surveyURL))

                            //                            let dateFormatter = DateFormatter()
                            //                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            //                            if let date = dateFormatter.date(from: terminationDate ?? "") {
                            if let date = self.state.terminations.convertStringToDate(dateString: terminationDate ?? "")
                            {
                                actions.append(.openTerminationSuccess)
                            } else {
                                actions.append(.openTerminationFailScreen)
                            }

                        } else if let nextStep = step.asFlowTerminationDeletionStep {
                            let disclaimer = nextStep.disclaimer
                            actions.append(.openTerminationDeletionScreen)

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

        case let .sendTerminationDate(terminationDate):
            var actions = [ContractAction]()
            actions.append(.setTerminationDate(date: terminationDate))

            //            let dateFormatter = DateFormatter()
            //            dateFormatter.dateFormat = "yyyy-MM-dd"
            //            let inputDateToString = dateFormatter.string(from: terminationDate)
            let terminationDate = self.state.terminations.terminationDate
            let inputDateToString = self.state.terminations.convertDateToString(date: terminationDate ?? Date()) ?? ""

            let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)
            let context = self.state.terminations.context

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowTerminationDateNextMutation(
                            input: terminationDateInput,
                            context: self.state.terminations.context
                        )
                    )
                    .onValue { data in

                        let context = data.flowTerminationDateNext.context
                        let step = data.flowTerminationDateNext.currentStep
                        actions.append(.setContext(context: context))

                        if let nextStep = step.asFlowTerminationSuccessStep {
                            let surveyURL = nextStep.surveyUrl
                            actions.append(.openTerminationSuccess)
                        } else if let nextStep = step.asFlowTerminationFailedStep {
                            actions.append(.openTerminationFailScreen)
                        } else if let nextStep = step.asFlowTerminationDateStep {
                            actions.append(
                                .openTerminationSetDateScreen(context: self.state.terminations.context ?? "")
                            )
                        } else if let nextStep = step.asFlowTerminationDeletionStep {
                            let disclaimer = nextStep.disclaimer
                            actions.append(.setDisclaimer(disclaimer: disclaimer))
                            actions.append(.deleteTermination)

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

        case let .deleteTermination:

            return FiniteSignal { callback in
                self.octopus.client
                    .perform(
                        mutation: OctopusGraphQL.FlowTerminationDeletionNextMutation(
                            context: self.state.terminations.context ?? ""
                        )
                    )
                    .onValue { data in

                        var actions = [ContractAction]()
                        let context = data.flowTerminationDeletionNext.context
                        actions.append(.setContext(context: context))

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

        case let .setTerminationDetails(id, minDate, maxDate):
            newState.terminations.id = id
            newState.terminations.minDate = minDate
            newState.terminations.maxDate = maxDate
            newState.terminations.terminationDate = nil

        case let .setDisclaimer(disclaimer):
            newState.terminations.disclaimer = disclaimer

        case let .setContext(context):
            newState.terminations.context = context

        case let .setSurveyURL(surveyURL):
            newState.terminations.surveyURL = surveyURL

        case let .setTerminationDate(date):
            newState.terminations.terminationDate = date

        default:
            break
        }

        return newState
    }
}
