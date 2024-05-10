import Presentation
import hCore
import hGraphQL

public class TerminateContractsOctopus: TerminateContractsService {
    public init() {}

    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        let mutation = OctopusGraphQL.FlowTerminationStartMutation(
            input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId),
            context: nil
        )
        //        return try await mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
        let suboptions = [
            TerminationFlowSurveyStepModelOption(
                id: "optionId3",
                title: "Option title 3",
                suggestion: nil,
                feedBack: .init(
                    id: "feedbackId",
                    isRequired: true
                ),
                subOptions: nil
            )
        ]
        let options = [
            TerminationFlowSurveyStepModelOption(
                id: "optionId",
                title: "Option title",
                suggestion: .action(
                    action: .init(
                        id: "actionId",
                        action: .updateAddress
                    )
                ),
                feedBack: nil,
                subOptions: suboptions
            ),
            .init(
                id: "option44",
                title: "Option with url",
                suggestion: .redirect(
                    redirect: .init(
                        id: "idOfRedirect",
                        url: "https://www.hedvig.com",
                        description: "Description",
                        buttonTitle: "Button title"
                    )
                ),
                feedBack: nil,
                subOptions: nil
            ),
            .init(
                id: "optionId2",
                title: "Option title 2",
                suggestion: nil,
                feedBack: .init(
                    id: "feedbackId",
                    isRequired: true
                ),
                subOptions: nil
            ),
        ]

        return .init(
            context: "",
            action: .stepModelAction(action: .setTerminationSurveyStep(model: .init(id: "id", options: options)))
        )
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)
        let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
            input: terminationDateInput,
            context: terminationContext
        )
        return try await mutation.execute(\.flowTerminationDateNext.fragments.flowTerminationFragment.currentStep)
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        let store: TerminationContractStore = globalPresentableStoreContainer.get()
        let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
            context: terminationContext,
            input: GraphQLNullable(optionalValue: store.state.terminationDeleteStep?.returnDeltionInput())
        )
        return try await mutation.execute(\.flowTerminationDeletionNext.fragments.flowTerminationFragment.currentStep)
    }

    public func sendSurvey(option: String, inputData: String?) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow(afterCancellationFinished: false))
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
    ) async throws -> TerminateStepResponse
    where
        TerminationStep.To == TerminationContractAction,
        Self.Data: TerminationStepContext
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
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
