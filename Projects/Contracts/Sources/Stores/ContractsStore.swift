import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ContractStore: LoadingStateStore<ContractState, ContractAction, ContractLoadingAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ContractState,
        _ action: ContractAction
    ) -> FiniteSignal<ContractAction>? {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
        case .fetchCrossSale:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client.fetch(query: OctopusGraphQL.CrossSellsQuery())
                    .onValue({ data in
                        let crossSells = data.currentMember.fragments.crossSellFragment.crossSells.compactMap({
                            CrossSell($0)
                        })
                        callback(.value(.setCrossSells(crossSells: crossSells)))
                    })
                return disposeBag
            }
        case .fetchContractBundles:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetchActiveContractBundles(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                    .onValue { activeContractBundles in
                        callback(
                            .value(ContractAction.setContractBundles(activeContractBundles: activeContractBundles))
                        )
                        callback(.value(.fetchContractBundlesDone))
                    }
                    .onError { [unowned self] error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .fetchContractBundles)
                        } else {
                            if !self.state.hasLoadedContractBundlesOnce {
                                self.setError(L10n.General.errorBody, for: .fetchContractBundles)
                            }
                        }
                        callback(.value(.fetchContractBundlesDone))
                    }
                return disposeBag
            }
        case .getTravelCertificateSpecification:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(query: OctopusGraphQL.TravelCertificateQuery())
                    .onValue { data in
                        let email = data.currentMember.email
                        let specification = TravelInsuranceSpecification(
                            data.currentMember.travelCertificateSpecifications,
                            email: email
                        )
                        callback(.value(.setTravelCertificateSpecification(specification: specification)))
                    }
                    .onError { error in
                        // TODO
                    }
                return disposeBag
            }
        case .fetchContracts:
            return FiniteSignal { [unowned self] callback in
                let disposeBag = DisposeBag()
                disposeBag += self.giraffe.client
                    .fetchContracts(locale: Localization.Locale.currentLocale.asGraphQLLocale())
                    .onValue { contracts in
                        if getState().contracts != contracts {
                            callback(.value(.setContracts(contracts: contracts)))
                        } else {
                            self.removeLoading(for: .fetchContracts)
                        }
                        callback(.value(.fetchContractsDone))
                    }
                    .onError { error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .fetchContracts)
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchContracts)
                        }
                        callback(.value(.fetchContractsDone))
                    }
                return disposeBag
            }
        case .fetch:
            return [
                .fetchCrossSale,
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
            let mutation = OctopusGraphQL.FlowTerminationStartMutation(
                input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId)
            )
            return FiniteSignal { [unowned self] callback in
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
                        self.removeLoading(for: .startTermination)
                    }
                    .onError { error in
                        self.setError(L10n.General.errorBody, for: .startTermination)
                    }
                return disposeBag
            }

        case let .sendTerminationDate(terminationDate):
            let inputDateToString = terminationDate.localDateString
            let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)

            let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
                input: terminationDateInput,
                context: terminationContext
            )
            return FiniteSignal { [unowned self] callback in
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
                        self.removeLoading(for: .sendTerminationDate)
                    }
                    .onError { error in
                        if ApplicationContext.shared.isDemoMode {
                            self.removeLoading(for: .sendTerminationDate)
                        } else {
                            self.setError(L10n.General.errorBody, for: .sendTerminationDate)
                        }
                    }
                return disposeBag
            }

        case .deleteTermination:
            let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
                context: terminationContext,
                input: state.terminationDeleteStep?.returnDeltionInput()
            )

            return FiniteSignal { [unowned self] callback in
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
                        self.removeLoading(for: .deleteTermination)
                    }
                    .onError { error in
                        self.setError(L10n.General.errorBody, for: .deleteTermination)
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
        case .fetchContractBundles:
            if !newState.hasLoadedContractBundlesOnce {
                setLoading(for: .fetchContractBundles)
            }
        case .fetchContracts:
            setLoading(for: .fetchContracts)
        case .setContractBundles(let activeContractBundles):
            newState.hasLoadedContractBundlesOnce = true
            removeLoading(for: .fetchContractBundles)
            guard activeContractBundles != state.contractBundles else { return newState }
            newState.contractBundles = activeContractBundles
        case let .setContracts(contracts):
            removeLoading(for: .fetchContracts)
            newState.contracts = contracts
        case .setCrossSells(let crossSells):
            newState.crossSells = crossSells
        case let .hasSeenCrossSells(value):
            newState.crossSells = newState.crossSells.map { crossSell in
                var newCrossSell = crossSell
                newCrossSell.hasBeenSeen = value
                return newCrossSell
            }
        case let .setFocusedCrossSell(focusedCrossSell):
            newState.focusedCrossSell = focusedCrossSell
        case .didSignFocusedCrossSell:
            newState.focusedCrossSell = nil
            newState.signedCrossSells = [newState.signedCrossSells, [newState.focusedCrossSell].compactMap { $0 }]
                .flatMap { $0 }
        case .resetSignedCrossSells:
            newState.signedCrossSells = []
        case .startTermination:
            setLoading(for: .startTermination)
        case let .setTerminationContext(context):
            newState.currentTerminationContext = context

        case let .setTerminationContractId(id):
            newState.terminationContractId = id
        case .sendTerminationDate:
            self.setLoading(for: .sendTerminationDate)
        case .deleteTermination:
            self.setLoading(for: .deleteTermination)
        case let .stepModelAction(step):
            switch step {
            case let .setTerminationDateStep(model):
                newState.terminationDateStep = model
            case let .setTerminationDeletion(model):
                newState.terminationDeleteStep = model
            case let .setSuccessStep(model):
                newState.successStep = model
            case let .setFailedStep(model):
                newState.failedStep = model
            }
        case let .setTravelCertificateSpecification(specification):
            let travelStore: TravelInsuranceStore = globalPresentableStoreContainer.get()
            travelStore.send(.setTravelInsurancesData(specification: specification))
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
        var navigationAction: TerminationNavigationAction?
        if let step = currentStep.fragments.flowTerminationDateStepFragment {
            let model = TerminationFlowDateNextStepModel(with: step)
            actions.append(.stepModelAction(action: .setTerminationDateStep(model: model)))
            navigationAction = .openTerminationSetDateScreen
        } else if let step = currentStep.fragments.flowTerminationDeletionFragment {
            let model = TerminationFlowDeletionNextModel(with: step)
            actions.append(.stepModelAction(action: .setTerminationDeletion(model: model)))
            navigationAction = .openTerminationDeletionScreen
        } else if let step = currentStep.fragments.flowTerminationFailedFragment {
            let model = TerminationFlowFailedNextModel(with: step)
            actions.append(.stepModelAction(action: .setFailedStep(model: model)))
            navigationAction = .openTerminationFailScreen

        } else if let step = currentStep.fragments.flowTerminationSuccessFragment {
            let model = TerminationFlowSuccessNextModel(with: step)
            actions.append(.stepModelAction(action: .setSuccessStep(model: model)))
            navigationAction = .openTerminationSuccessScreen
        } else {
            navigationAction = .openTerminationUpdateAppScreen
        }
        if let navigationAction {
            actions.append(.navigationAction(action: navigationAction))
            if case .startTermination = action {
                actions.append(.terminationInitialNavigation(action: navigationAction))
            }
        }
        actions.forEach { action in
            callback(.value(action))
        }
    }
}
