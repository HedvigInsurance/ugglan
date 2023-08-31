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
        case .startTermination(let contractId, _):
            let mutation = OctopusGraphQL.FlowTerminationStartMutation(
                input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId)
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
        case let .startTermination(_, contractName):
            newState.contractName = contractName
        //            setLoading(for: .startTermination)
        case let .setTerminationContext(context):
            newState.currentTerminationContext = context
        case let .setTerminationContractId(id):
            newState.terminationContractId = id
        //        case .sendTerminationDate:
        //            self.setLoading(for: .sendTerminationDate)
        //        case .deleteTermination:
        //            self.setLoading(for: .deleteTermination)
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
                send(.navigationAction(action: .openTerminationSuccessScreen))
            case let .setFailedStep(model):
                newState.failedStep = model
                send(.navigationAction(action: .openTerminationFailScreen))
            }
        case let .setTerminationDate(terminationDate):
            newState.terminationDateStep?.date = terminationDate
        default:
            break
        }

        return newState
    }
}
