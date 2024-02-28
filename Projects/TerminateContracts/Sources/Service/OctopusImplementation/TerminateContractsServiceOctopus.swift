import Flow
import Presentation
import hCore
import hGraphQL

public class TerminateContractsOctopus: TerminateContractsService {
    public init() {}

    public func startTermination(contractId: String) async throws -> TeminateStepResponse {
        let mutation = OctopusGraphQL.FlowTerminationStartMutation(
            input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId),
            context: nil
        )
        return try await mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TeminateStepResponse {
        let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)
        let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
            input: terminationDateInput,
            context: terminationContext
        )
        return try await mutation.execute(\.flowTerminationDateNext.fragments.flowTerminationFragment.currentStep)
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TeminateStepResponse {
        let store: TerminationContractStore = globalPresentableStoreContainer.get()
        let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
            context: terminationContext,
            input: GraphQLNullable(optionalValue: store.state.terminationDeleteStep?.returnDeltionInput())
        )
        return try await mutation.execute(\.flowTerminationDeletionNext.fragments.flowTerminationFragment.currentStep)
    }
}

protocol Into {
    associatedtype To
    func into() -> To
}

extension OctopusGraphQL.FlowTerminationFragment.CurrentStep: Into {
    func into() -> TerminationContractAction {
        if let step = self.asFlowTerminationDateStep?.fragments.flowTerminationDateStepFragment {
            return .stepModelAction(action: .setTerminationDateStep(model: .init(with: step)))
        } else if let step = self.asFlowTerminationDeletionStep?.fragments.flowTerminationDeletionFragment {
            return .stepModelAction(action: .setTerminationDeletion(model: .init(with: step)))
        } else if let step = self.asFlowTerminationFailedStep?.fragments.flowTerminationFailedFragment {
            return .stepModelAction(action: .setFailedStep(model: .init(with: step)))
        } else if let step = self.asFlowTerminationSuccessStep?.fragments.flowTerminationSuccessFragment {
            return .stepModelAction(action: .setSuccessStep(model: .init(with: step)))
        } else {
            return .navigationAction(action: .openTerminationUpdateAppScreen)
        }
    }
}

extension GraphQLMutation {
    func execute<TerminationStep: Into>(
        _ keyPath: KeyPath<Self.Data, TerminationStep>
    ) async throws -> TeminateStepResponse
    where
        TerminationStep.To == TerminationContractAction,
        Self.Data: TerminationStepContext
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        let disposeBag = DisposeBag()
        let store: TerminationContractStore = globalPresentableStoreContainer.get()
        let data = try await octopus.client.perform(mutation: self)
        let context = data.getContext()
        let action = data[keyPath: keyPath].into()
        return .init(context: context, action: action)
    }
}

protocol TerminationStepContext {
    func getContext() -> String
}

extension OctopusGraphQL.FlowTerminationStartMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationStart.context
    }
}

extension OctopusGraphQL.FlowTerminationDateNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationDateNext.context
    }
}

extension OctopusGraphQL.FlowTerminationDeletionNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationDeletionNext.context
    }
}
