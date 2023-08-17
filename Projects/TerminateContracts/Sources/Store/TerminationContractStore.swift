import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class TerminationContractStore: LoadingStateStore<
    TerminationContractState, TerminationContractAction, TerminationContractLoadingAction
>
{
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> TerminationContractState,
        _ action: TerminationContractAction
    ) -> FiniteSignal<TerminationContractAction>? {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
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

        case .sendTerminationDate:
            let inputDateToString = self.state.terminationDateStep?.date?.localDateString ?? ""
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

    public override func reduce(
        _ state: TerminationContractState,
        _ action: TerminationContractAction
    ) -> TerminationContractState {
        var newState = state
        switch action {
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
        case let .setTerminationDate(terminationDate):
            newState.terminationDateStep?.date = terminationDate
        default:
            break
        }

        return newState
    }
}

extension OctopusGraphQL.FlowTerminationFragment {
    func executeNextStepActions(
        for action: TerminationContractAction,
        callback: (Event<TerminationContractAction>) -> Void
    ) {
        let currentStep = self.currentStep
        var actions = [TerminationContractAction]()
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
