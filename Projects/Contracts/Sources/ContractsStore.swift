import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: StateStore<ContractState, ContractAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        let terminationContext = state.currentTerminationContext ?? ""
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
            self.send(.setLoadingState(action: action, state: .loading))
            let mutation = OctopusGraphQL.FlowTerminationStartMutation(
                input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId)
            )
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(
                            .value(.setTerminationContext(context: data.flowTerminationStart.context))
                        )
                        callback(.value(.setTerminationContractId(id: contractId)))

                        data.flowTerminationStart.fragments.flowTerminationFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        log.error("Error: \(error)")
                    }
                return disposeBag
            }

        case let .sendTerminationDate(terminationDate):
            self.send(.setLoadingState(action: action, state: .loading))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let inputDateToString = dateFormatter.string(from: terminationDate)

            let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)

            let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
                input: terminationDateInput,
                context: terminationContext
            )
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(
                            .value(
                                .setTerminationContext(context: data.flowTerminationDateNext.context)
                            )
                        )
                        data.flowTerminationDateNext.fragments.flowTerminationFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        log.error("Error: \(error)")
                    }
                return disposeBag
            }

        case .deleteTermination:
            self.send(.setLoadingState(action: action, state: .loading))
            let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
                context: terminationContext,
                input: state.terminationDeleteStep?.returnDeltionInput()
            )

            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue { data in
                        callback(
                            .value(
                                .setTerminationContext(context: data.flowTerminationDeletionNext.context)
                            )
                        )
                        data.flowTerminationDeletionNext.fragments.flowTerminationFragment.executeNextStepActions(
                            for: action,
                            callback: callback
                        )
                        callback(.value(.setLoadingState(action: action, state: nil)))
                    }
                    .onError { error in
                        log.error("Error: \(error)")
                    }
                return disposeBag
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

        case let .setTerminationContext(context):
            newState.currentTerminationContext = context

        case let .setTerminationContractId(id):
            newState.terminationContractId = id

        case let .stepModelAction(step):
            switch step {
            case let .setTerminationDateStep(model):
                newState.terminationDateStep = model
            case .setTerminationDeletion(let model):
                newState.terminationDeleteStep = model
            case .setSuccessStep(let model):
                newState.successStep = model
            case .setFailedStep(let model):
                newState.failedStep = model
            }

        default:
            break
        }

        return newState
    }
}

extension OctopusGraphQL.FlowTerminationFragment {
    func executeNextStepActions(for action: ContractAction, callback: (Event<ContractAction>) -> Void) {
        let currentStep = self.currentStep
        var actions = [ContractAction]()

        if let step = currentStep.fragments.flowTerminationDateStepFragment {
            let model = TerminationFlowDateNextStepModel(with: step)
            actions.append(.stepModelAction(action: .setTerminationDateStep(model: model)))
            actions.append(.navigationAction(action: .openTerminationSetDateScreen))

        } else if let step = currentStep.fragments.flowTerminationDeletionFragment {
            let model = TerminationFlowDeletionNextModel(with: step)
            actions.append(.stepModelAction(action: .setTerminationDeletion(model: model)))
            actions.append(.navigationAction(action: .openTerminationDeletionScreen))

        } else if let step = currentStep.fragments.flowTerminationFailedFragment {
            let model = TerminationFlowFailedNextModel(with: step)
            actions.append(.stepModelAction(action: .setFailedStep(model: model)))
            actions.append(.navigationAction(action: .openTerminationFailScreen))

        } else if let step = currentStep.fragments.flowTerminationSuccessFragment {
            let model = TerminationFlowSuccessNextModel(with: step)
            actions.append(.stepModelAction(action: .setSuccessStep(model: model)))
            actions.append(.navigationAction(action: .openTerminationSuccessScreen))
        } else {
            actions.append(.navigationAction(action: .openTerminationUpdateAppScreen))
        }

        actions.forEach { action in
            callback(.value(action))
        }
    }
}
