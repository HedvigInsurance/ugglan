import PresentableStore
import hCore
import hGraphQL

public class TerminateContractsClientOctopus: TerminateContractsClient {
    public init() {}

    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        let mutation = OctopusGraphQL.FlowTerminationStartMutation(
            input: OctopusGraphQL.FlowTerminationStartInput(contractId: contractId),
            context: nil
        )
        return try await mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
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

    public func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        let input = OctopusGraphQL.FlowTerminationSurveyDataInput(
            optionId: option,
            text: GraphQLNullable.init(optionalValue: inputData)
        )
        let data = OctopusGraphQL.FlowTerminationSurveyInput(data: input)
        let mutation = OctopusGraphQL.FlowTerminationSurveyNextMutation(input: data, context: terminationContext)
        return try await mutation.execute(\.flowTerminationSurveyNext.fragments.flowTerminationFragment.currentStep)
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
        } else if let step = self.asFlowTerminationSurveyStep?.fragments.flowTerminationSurveyStepFragment {
            return .stepModelAction(action: .setTerminationSurveyStep(model: .init(with: step)))
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

extension OctopusGraphQL.FlowTerminationSurveyNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        return self.flowTerminationSurveyNext.context
    }
}

extension TerminationFlowSurveyStepModel {
    init(with data: OctopusGraphQL.FlowTerminationSurveyStepFragment) {
        var options = [TerminationFlowSurveyStepModelOption]()
        for layer1 in data.options {
            var subOptions = [TerminationFlowSurveyStepModelOption]()
            layer1.subOptions?
                .forEach({ subOption in
                    var subSubOptions = [TerminationFlowSurveyStepModelOption]()
                    subOption.subOptions?
                        .forEach({ subSubOption in
                            var subSubSubOptions = [TerminationFlowSurveyStepModelOption]()
                            subSubOption.subOptions?
                                .forEach({ subSubOption in
                                    subSubSubOptions.append(
                                        .init(
                                            with: subSubOption.fragments.flowTerminationSurveyStepOptionFragment,
                                            subOptions: []
                                        )
                                    )
                                })
                            subSubOptions.append(
                                .init(
                                    with: subSubOption.fragments.flowTerminationSurveyStepOptionFragment,
                                    subOptions: subSubSubOptions
                                )
                            )
                        })
                    subOptions.append(
                        .init(
                            with: subOption.fragments.flowTerminationSurveyStepOptionFragment,
                            subOptions: subSubOptions
                        )
                    )
                })
            let stepOptionFragment = layer1.fragments.flowTerminationSurveyStepOptionFragment
            options.append(.init(with: stepOptionFragment, subOptions: subOptions))
        }
        id = data.id
        self.options = options
    }
}

extension TerminationFlowSurveyStepModelOption {

    init(
        with data: OctopusGraphQL.FlowTerminationSurveyStepOptionFragment,
        subOptions: [TerminationFlowSurveyStepModelOption]
    ) {
        id = data.id
        title = data.title
        suggestion = data.suggestion?.fragments.flowTerminationSurveyOptionSuggestionFragment.asSuggestion
        feedBack = data.feedBack?.fragments.flowTerminationSurveyOptionFeedbackFragment.asFeedback
        self.subOptions = subOptions
    }
}
extension OctopusGraphQL.FlowTerminationSurveyOptionSuggestionFragment {
    var asSuggestion: TerminationFlowSurveyStepSuggestion? {
        if let optionActionSuggestion = self.asFlowTerminationSurveyOptionSuggestionAction,
            let action = optionActionSuggestion.action.asFlowTerminationSurveyRedirectAction
        {
            let buttonTitle = optionActionSuggestion.buttonTitle
            let description = optionActionSuggestion.description
            return .action(
                action: .init(
                    id: optionActionSuggestion.id,
                    action: action,
                    description: description,
                    buttonTitle: buttonTitle
                )
            )
        } else if let optionRedirectSuggestion = self.asFlowTerminationSurveyOptionSuggestionRedirect {
            return .redirect(
                redirect: .init(
                    id: optionRedirectSuggestion.id,
                    url: optionRedirectSuggestion.url,
                    description: optionRedirectSuggestion.description,
                    buttonTitle: optionRedirectSuggestion.buttonTitle
                )
            )
        }
        return nil
    }
}

extension GraphQLEnum<OctopusGraphQL.FlowTerminationSurveyRedirectAction> {
    var asFlowTerminationSurveyRedirectAction: FlowTerminationSurveyRedirectAction? {
        switch self {
        case .case(let t):
            switch t {
            case .updateAddress:
                return .updateAddress
            }
        case .unknown:
            return nil
        }
    }
}

extension OctopusGraphQL.FlowTerminationSurveyOptionFeedbackFragment {
    var asFeedback: TerminationFlowSurveyStepFeedback? {
        .init(id: self.id, isRequired: self.isRequired)
    }
}

extension TerminationFlowDateNextStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowTerminationDateStepFragment
    ) {
        self.id = data.id
        self.minDate = data.minDate
        self.maxDate = data.maxDate
        self.date = nil
    }
}

extension TerminationFlowFailedNextModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowTerminationFailedFragment
    ) {
        self.id = data.id
    }
}

extension TerminationFlowDeletionNextModel {
    init(
        with data: OctopusGraphQL.FlowTerminationDeletionFragment
    ) {
        self.id = data.id
    }

    public func returnDeltionInput() -> OctopusGraphQL.FlowTerminationDeletionInput {
        return OctopusGraphQL.FlowTerminationDeletionInput(confirmed: true)
    }
}
