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
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> TerminationContractState,
        _ action: TerminationContractAction
    ) -> FiniteSignal<TerminationContractAction>? {
        let terminationContext = state.currentTerminationContext ?? ""
        switch action {
        case let .startTermination(config):
            let mutation = OctopusGraphQL.FlowTerminationStartMutation(
                input: OctopusGraphQL.FlowTerminationStartInput(contractId: config.contractId)
            )
            return mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
        case .sendTerminationDate:
            let inputDateToString = self.state.terminationDateStep?.date?.localDateString ?? ""
            let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)

            let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
                input: terminationDateInput,
                context: terminationContext
            )
            return mutation.execute(\.flowTerminationDateNext.fragments.flowTerminationFragment.currentStep)
        case .deleteTermination:
            let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
                context: terminationContext,
                input: state.terminationDeleteStep?.returnDeltionInput()
            )
            return mutation.execute(\.flowTerminationDeletionNext.fragments.flowTerminationFragment.currentStep)
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
        case let .startTermination(config):
            newState.config = config
        case let .setTerminationContext(context):
            newState.currentTerminationContext = context
        case let .setTerminationContractId(id):
            newState.terminationContractId = id
        case let .stepModelAction(step):
            switch step {
            case let .setTerminationDateStep(model):
                newState.terminationDateStep = model
                send(.navigationAction(action: .openSetTerminationDateScreen))
            case let .setTerminationDeletion(model):
                newState.terminationDeleteStep = model
                send(.navigationAction(action: .openTerminationDeletionScreen))
            case let .setSuccessStep(model):
                newState.successStep = model
                log.info("termination success", attributes: ["contractId": newState.config?.contractId])
                send(.navigationAction(action: .openTerminationSuccessScreen))
            case let .setFailedStep(model):
                log.info("termination failed", attributes: ["contractId": newState.config?.contractId])
                newState.failedStep = model
                send(.navigationAction(action: .openTerminationFailScreen))
            }
        case let .setTerminationDate(terminationDate):
            newState.terminationDateStep?.date = terminationDate
        case .setTerminationisDeletion:
            newState.config?.isDeletion = true
        default:
            break
        }

        return newState
    }
}
