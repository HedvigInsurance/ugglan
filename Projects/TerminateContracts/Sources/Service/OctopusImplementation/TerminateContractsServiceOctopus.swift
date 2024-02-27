import Flow
import Presentation
import hGraphQL

public class TerminateContractsOctopus: TerminateContractsService {
    public init() {}

    public func startTermination(contractId: String) -> FiniteSignal<TerminationContractAction> {
        let mutation = OctopusGraphQL.FlowTerminationStartMutation(
            input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId),
            context: nil
        )
        return mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) -> FiniteSignal<TerminationContractAction> {
        let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)
        let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
            input: terminationDateInput,
            context: terminationContext
        )
        return mutation.execute(\.flowTerminationDateNext.fragments.flowTerminationFragment.currentStep)
    }

    public func sendConfirmDelete(terminationContext: String) -> FiniteSignal<TerminationContractAction> {
        let store: TerminationContractStore = globalPresentableStoreContainer.get()
        let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
            context: terminationContext,
            input: GraphQLNullable(optionalValue: store.state.terminationDeleteStep?.returnDeltionInput())
        )
        return mutation.execute(\.flowTerminationDeletionNext.fragments.flowTerminationFragment.currentStep)
    }
}
