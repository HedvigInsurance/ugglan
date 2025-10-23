import Foundation
import TerminateContracts
import hCore
import hGraphQL

class TerminateContractsClientOctopus: TerminateContractsClient {
    @Inject private var octopus: hOctopus

    func startTermination(contractId: String) async throws -> TerminateStepResponse {
        let mutation = OctopusGraphQL.FlowTerminationStartMutation(
            input: OctopusGraphQL.FlowTerminationStartInput(
                contractId: contractId,
                supportedSteps: GraphQLNullable(optionalValue: supportedSteps())
            ),
            context: nil
        )
        return try await mutation.execute(\.flowTerminationStart.fragments.flowTerminationFragment.currentStep)
    }

    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        let terminationDateInput = OctopusGraphQL.FlowTerminationDateInput(terminationDate: inputDateToString)
        let mutation = OctopusGraphQL.FlowTerminationDateNextMutation(
            input: terminationDateInput,
            context: terminationContext
        )
        async let dataTask = mutation.execute(\.flowTerminationDateNext.fragments.flowTerminationFragment.currentStep)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        let data = try await dataTask
        return data
    }

    func sendConfirmDelete(
        terminationContext: String,
        model: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse {
        let mutation = OctopusGraphQL.FlowTerminationDeletionNextMutation(
            context: terminationContext,
            input: GraphQLNullable(optionalValue: model?.returnDeletionInput())
        )
        async let dataTask = mutation.execute(
            \.flowTerminationDeletionNext.fragments.flowTerminationFragment.currentStep
        )
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return try await dataTask
    }

    func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        let input = OctopusGraphQL.FlowTerminationSurveyDataInput(
            optionId: option,
            text: GraphQLNullable(optionalValue: inputData)
        )
        let data = OctopusGraphQL.FlowTerminationSurveyInput(data: input)
        let mutation = OctopusGraphQL.FlowTerminationSurveyNextMutation(input: data, context: terminationContext)
        return try await mutation.execute(\.flowTerminationSurveyNext.fragments.flowTerminationFragment.currentStep)
    }

    public func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        let input = OctopusGraphQL.TerminationFlowNotificationInput(
            contractId: contractId,
            terminationDate: date.localDateString
        )

        let query = OctopusGraphQL.TerminationFlowNotificationQuery(input: input)
        let data = try await octopus.client.fetch(query: query)

        guard let terminationFlowNotification = data.currentMember.terminationFlowNotification else { return nil }

        return .init(with: terminationFlowNotification.fragments.flowTerminationNotificationFragment)
    }

    func supportedSteps() -> [OctopusGraphQL.ID] {
        [
            OctopusGraphQL.Objects.FlowTerminationDateStep.typename,
            OctopusGraphQL.Objects.FlowTerminationFailedStep.typename,
            OctopusGraphQL.Objects.FlowTerminationSurveyStep.typename,
            OctopusGraphQL.Objects.FlowTerminationSuccessStep.typename,
            OctopusGraphQL.Objects.FlowTerminationDeletionStep.typename,
            OctopusGraphQL.Objects.FlowTerminationCarAutoDecomStep.typename,
        ]
    }
}

extension TerminationNotification {
    init(
        with data: OctopusGraphQL.FlowTerminationNotificationFragment
    ) {
        self.init(
            message: data.message,
            type: data.type.asNotificationType
        )
    }
}

private protocol Into {
    associatedtype To
    func into(with progress: Float) -> To
}

extension OctopusGraphQL.FlowTerminationFragment.CurrentStep: Into {
    func into(with progress: Float) -> (step: TerminationContractStep, progress: Float?) {
        if let step = asFlowTerminationDateStep?.fragments.flowTerminationDateStepFragment {
            return (step: .setTerminationDateStep(model: .init(with: step)), progress)
        } else if let step = asFlowTerminationDeletionStep?.fragments.flowTerminationDeletionFragment {
            return (step: .setTerminationDeletion(model: .init(with: step)), progress)
        } else if let step = asFlowTerminationFailedStep?.fragments.flowTerminationFailedFragment {
            return (step: .setFailedStep(model: .init(with: step)), nil)
        } else if let step = asFlowTerminationSuccessStep?.fragments.flowTerminationSuccessFragment {
            return (step: .setSuccessStep(model: .init(terminationDate: step.terminationDate)), nil)
        } else if let step = asFlowTerminationSurveyStep?.fragments.flowTerminationSurveyStepFragment {
            return (step: .setTerminationSurveyStep(model: .init(with: step)), progress)
        } else if let step = asFlowTerminationCarAutoDecomStep?.fragments.flowTerminationCarAutoDecomStepFragment {
            return (step: .setDeflectAutoDecom(model: .init(with: step)), progress)
        } else {
            return (step: .openTerminationUpdateAppScreen, nil)
        }
    }
}

@MainActor
extension GraphQLMutation {
    fileprivate func execute<TerminationStep: Into>(
        _ keyPath: KeyPath<Self.Data, TerminationStep>
    ) async throws -> TerminateStepResponse
    where
        TerminationStep.To == (step: TerminationContractStep, progress: Float?),
        Self.Data: TerminationStepContext & TerminationStepProgress,
        Self.ResponseFormat == SingleResponseFormat
    {
        let octopus: hOctopus = Dependencies.shared.resolve()
        let data = try await octopus.client.mutation(mutation: self)!
        let context = data.getContext()
        let progress = data.getProgress()
        let stepWithNewProgress = data[keyPath: keyPath].into(with: progress)
        return .init(context: context, step: stepWithNewProgress.step, progress: stepWithNewProgress.progress)
    }
}

protocol TerminationStepProgress {
    func getProgress() -> Float
}

protocol TerminationStepContext {
    func getContext() -> String
}

extension OctopusGraphQL.FlowTerminationStartMutation.Data: TerminationStepContext {
    func getContext() -> String {
        flowTerminationStart.context
    }
}

extension OctopusGraphQL.FlowTerminationDateNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        flowTerminationDateNext.context
    }
}

extension OctopusGraphQL.FlowTerminationDeletionNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        flowTerminationDeletionNext.context
    }
}

extension OctopusGraphQL.FlowTerminationSurveyNextMutation.Data: TerminationStepContext {
    func getContext() -> String {
        flowTerminationSurveyNext.context
    }
}

extension OctopusGraphQL.FlowTerminationStartMutation.Data: TerminationStepProgress {
    func getProgress() -> Float {
        Float(flowTerminationStart.progress?.clearedSteps ?? 0)
            / Float(flowTerminationStart.progress?.totalSteps ?? 0)
    }
}

extension OctopusGraphQL.FlowTerminationDateNextMutation.Data: TerminationStepProgress {
    func getProgress() -> Float {
        Float(flowTerminationDateNext.progress?.clearedSteps ?? 0)
            / Float(flowTerminationDateNext.progress?.totalSteps ?? 0)
    }
}

extension OctopusGraphQL.FlowTerminationDeletionNextMutation.Data: TerminationStepProgress {
    func getProgress() -> Float {
        Float(flowTerminationDeletionNext.progress?.clearedSteps ?? 0)
            / Float(flowTerminationDeletionNext.progress?.totalSteps ?? 0)
    }
}

extension OctopusGraphQL.FlowTerminationSurveyNextMutation.Data: TerminationStepProgress {
    func getProgress() -> Float {
        Float(flowTerminationSurveyNext.progress?.clearedSteps ?? 0)
            / Float(flowTerminationSurveyNext.progress?.totalSteps ?? 0)
    }
}

extension TerminationFlowDeflectAutoDecomModel {
    init(with data: OctopusGraphQL.FlowTerminationCarAutoDecomStepFragment) {
        self.init()
    }
}

extension TerminationFlowSurveyStepModel {
    init(with data: OctopusGraphQL.FlowTerminationSurveyStepFragment) {
        var options = [TerminationFlowSurveyStepModelOption]()
        for layer1 in data.options {
            var subOptions = [TerminationFlowSurveyStepModelOption]()
            layer1.subOptions?
                .forEach { subOption in
                    var subSubOptions = [TerminationFlowSurveyStepModelOption]()
                    subOption.subOptions?
                        .forEach { subSubOption in
                            var subSubSubOptions = [TerminationFlowSurveyStepModelOption]()
                            subSubOption.subOptions?
                                .forEach { subSubOption in
                                    subSubSubOptions.append(
                                        .init(
                                            with: subSubOption.fragments.flowTerminationSurveyStepOptionFragment,
                                            subOptions: []
                                        )
                                    )
                                }
                            subSubOptions.append(
                                .init(
                                    with: subSubOption.fragments.flowTerminationSurveyStepOptionFragment,
                                    subOptions: subSubSubOptions
                                )
                            )
                        }
                    subOptions.append(
                        .init(
                            with: subOption.fragments.flowTerminationSurveyStepOptionFragment,
                            subOptions: subSubOptions
                        )
                    )
                }
            let stepOptionFragment = layer1.fragments.flowTerminationSurveyStepOptionFragment
            options.append(.init(with: stepOptionFragment, subOptions: subOptions))
        }
        self.init(
            id: data.id,
            options: options,
            subTitleType: .default
        )
    }
}

extension TerminationFlowSurveyStepModelOption {
    init(
        with data: OctopusGraphQL.FlowTerminationSurveyStepOptionFragment,
        subOptions: [TerminationFlowSurveyStepModelOption]
    ) {
        self.init(
            id: data.id,
            title: data.title,
            suggestion: data.suggestion?.fragments.flowTerminationSurveyOptionSuggestionFragment.asSuggestion,
            feedBack: data.feedBack?.fragments.flowTerminationSurveyOptionFeedbackFragment.asFeedback,
            subOptions: subOptions
        )
    }
}

extension OctopusGraphQL.FlowTerminationSurveyOptionSuggestionFragment {
    var asSuggestion: TerminationFlowSurveyStepSuggestion? {
        if let optionActionSuggestion = asFlowTerminationSurveyOptionSuggestionAction,
            let action = optionActionSuggestion.action.asFlowTerminationSurveyRedirectAction
        {
            let buttonTitle = optionActionSuggestion.buttonTitle
            let description = optionActionSuggestion.description
            return .action(
                action: .init(
                    id: optionActionSuggestion.id,
                    action: action,
                    description: description,
                    buttonTitle: buttonTitle,
                    type: optionActionSuggestion.infoType.value?.asInfoType ?? .offer
                )
            )
        } else if let optionRedirectSuggestion = asFlowTerminationSurveyOptionSuggestionRedirect {
            return .redirect(
                redirect: .init(
                    id: optionRedirectSuggestion.id,
                    url: optionRedirectSuggestion.url,
                    description: optionRedirectSuggestion.description,
                    buttonTitle: optionRedirectSuggestion.buttonTitle,
                    type: optionRedirectSuggestion.infoType.value?.asInfoType ?? .offer
                )
            )
        } else if let optionSuggestionInfo = asFlowTerminationSurveyOptionSuggestionInfo {
            return .suggestionInfo(
                info: .init(
                    id: optionSuggestionInfo.id,
                    description: optionSuggestionInfo.description,
                    type: optionSuggestionInfo.infoType.value?.asInfoType ?? .offer
                )
            )
        }
        return nil
    }
}

extension GraphQLEnum<OctopusGraphQL.FlowTerminationSurveyRedirectAction> {
    var asFlowTerminationSurveyRedirectAction: FlowTerminationSurveyRedirectAction? {
        switch self {
        case let .case(t):
            switch t {
            case .updateAddress:
                return .updateAddress
            case .changeTierFoundBetterPrice:
                return .changeTierFoundBetterPrice
            case .changeTierMissingCoverageAndTerms:
                return .changeTierMissingCoverageAndTerms
            }
        case .unknown:
            return nil
        }
    }
}

extension OctopusGraphQL.FlowTerminationSurveyOptionFeedbackFragment {
    var asFeedback: TerminationFlowSurveyStepFeedback? {
        .init(id: id, isRequired: isRequired)
    }
}

extension OctopusGraphQL.FlowTerminationSurveyOptionSuggestionInfoType {
    var asInfoType: SurveySuggestionInfoType {
        switch self {
        case .info: return .info
        case .offer: return .offer
        }
    }
}

extension TerminationFlowDateNextStepModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowTerminationDateStepFragment
    ) {
        self.init(
            id: data.id,
            maxDate: data.maxDate,
            minDate: data.minDate,
            date: nil,
            extraCoverageItem: data.extraCoverage.map { .init(fragment: $0.fragments.extraCoverageItemFragment) }
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.FlowTerminationNotificationType> {
    var asNotificationType: TerminationNotificationType {
        switch self {
        case let .case(t):
            switch t {
            case .info:
                return .info
            case .warning:
                return .warning
            }
        default:
            return .info
        }
    }
}

extension ExtraCoverageItem {
    init(
        fragment: OctopusGraphQL.ExtraCoverageItemFragment
    ) {
        self.init(
            displayName: fragment.displayName,
            displayValue: fragment.displayValue
        )
    }
}

extension TerminationFlowFailedNextModel {
    fileprivate init(
        with data: OctopusGraphQL.FlowTerminationFailedFragment
    ) {
        self.init(id: data.id)
    }
}

extension TerminationFlowDeletionNextModel {
    init(
        with data: OctopusGraphQL.FlowTerminationDeletionFragment
    ) {
        self.init(
            id: data.id,
            extraCoverageItem: data.extraCoverage.map { .init(fragment: $0.fragments.extraCoverageItemFragment) }
        )
    }

    public func returnDeletionInput() -> OctopusGraphQL.FlowTerminationDeletionInput {
        OctopusGraphQL.FlowTerminationDeletionInput(confirmed: true)
    }
}
