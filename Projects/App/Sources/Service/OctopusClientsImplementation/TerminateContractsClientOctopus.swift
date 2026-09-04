import Foundation
import TerminateContracts
import hCore
import hGraphQL

// NOTE: The generated type paths below follow Apollo iOS codegen conventions.
// After running codegen, verify the exact type names in
// Projects/hGraphQL/Sources/Derived/GraphQL/Octopus/

private enum TerminationError: LocalizedError {
    case unsupportedActionType

    var errorDescription: String? {
        switch self {
        case .unsupportedActionType:
            return L10n.General.errorBody
        }
    }
}

class TerminateContractsClientOctopus: TerminateContractsClient {
    @Inject private var octopus: hOctopus

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        let query = OctopusGraphQL.TerminationSurveyQuery(
            contractId: contractId,
            redirectionEnabled: Dependencies.featureFlags().isTerminationRedirectionEnabled
        )
        let data = try await octopus.client.fetch(query: query)
        return try mapSurveyData(data.terminationSurvey)
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        let input = OctopusGraphQL.TerminationFlowTerminateContractInput(
            contractId: contractId,
            terminationDate: terminationDate,
            terminationSurveyOptionId: surveyOptionId,
            terminationComment: GraphQLNullable(optionalValue: comment)
        )
        let mutation = OctopusGraphQL.TerminateContractMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)!
        if let errorMessage = data.terminateContract.userError?.message {
            return .userError(message: errorMessage)
        }
        return .success
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        let input = OctopusGraphQL.TerminationFlowDeleteContractInput(
            contractId: contractId,
            terminationSurveyOptionId: surveyOptionId,
            terminationComment: GraphQLNullable(optionalValue: comment)
        )
        let mutation = OctopusGraphQL.DeleteContractMutation(input: input)
        let data = try await octopus.client.mutation(mutation: mutation)!
        if let errorMessage = data.deleteContract.userError?.message {
            return .userError(message: errorMessage)
        }
        return .success
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        let input = OctopusGraphQL.TerminationFlowNotificationInput(
            contractId: contractId,
            terminationDate: date.localDateString
        )
        let query = OctopusGraphQL.TerminationNotificationQuery(input: input)
        let data = try await octopus.client.fetch(query: query)
        guard let notification = data.currentMember.terminationNotification else { return nil }
        return .init(
            message: notification.message,
            type: notification.type == .case(.warning) ? .warning : .info
        )
    }
}

// MARK: - GraphQL → Domain Mapping

extension TerminateContractsClientOctopus {
    private func mapSurveyData(
        _ survey: OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey
    ) throws -> TerminationSurveyData {
        .init(
            options: survey.options.map { mapOption($0) },
            action: try mapAction(survey.action)
        )
    }

    private func mapOption(
        _ option: OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey.Option
    ) -> TerminationSurveyOption {
        option.fragments.terminationSurveyOptionFragment.asOption(
            subOptions: option.subOptions.map { subOption in
                subOption.fragments.terminationSurveyOptionFragment.asOption(
                    subOptions: subOption.subOptions.map { subSubOption in
                        subSubOption.fragments.terminationSurveyOptionFragment.asOption(
                            subOptions: subSubOption.subOptions.map { leaf in
                                leaf.fragments.terminationSurveyOptionFragment.asOption(subOptions: [])
                            }
                        )
                    }
                )
            }
        )
    }

    private func mapAction(
        _ action: OctopusGraphQL.TerminationSurveyQuery.Data.TerminationSurvey.Action
    ) throws -> TerminationAction {
        if let terminateWithDate = action.asTerminationFlowActionTerminateWithDate {
            return .terminateWithDate(
                minDate: terminateWithDate.minDate,
                maxDate: terminateWithDate.maxDate,
                extraCoverage: terminateWithDate.extraCoverage.map {
                    .init(
                        displayName: $0.fragments.terminationExtraCoverageItemFragment.displayName,
                        displayValue: $0.fragments.terminationExtraCoverageItemFragment.displayValue
                    )
                }
            )
        } else if let deleteInsurance = action.asTerminationFlowActionDeleteInsurance {
            return .deleteInsurance(
                extraCoverage: deleteInsurance.extraCoverage.map {
                    .init(
                        displayName: $0.fragments.terminationExtraCoverageItemFragment.displayName,
                        displayValue: $0.fragments.terminationExtraCoverageItemFragment.displayValue
                    )
                }
            )
        }
        throw TerminationError.unsupportedActionType
    }
}

extension OctopusGraphQL.TerminationSurveyOptionSuggestionFragment {
    var asSuggestion: TerminationSuggestion {
        .init(
            type: type.asTerminationSuggestionType,
            description: description,
            actionText: actionText,
            url: url
        )
    }
}

extension OctopusGraphQL.TerminationSurveyOptionFragment {
    func asOption(subOptions: [TerminationSurveyOption]) -> TerminationSurveyOption {
        .init(
            id: id,
            title: title,
            feedbackRequired: feedbackRequired,
            suggestion: suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
            redirection: redirection?.fragments.terminationSurveyOptionRedirectionFragment.asRedirection,
            subOptions: subOptions
        )
    }
}

extension OctopusGraphQL.TerminationSurveyOptionRedirectionFragment {
    var asRedirection: TerminationRedirection {
        .init(
            title: title,
            description: description,
            type: type.asTerminationRedirectionType,
            actionText: actionText,
            image: image.map { .init(url: $0.url, overlayText: $0.overlayText) }
        )
    }
}

extension GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionRedirectionType> {
    var asTerminationRedirectionType: TerminationRedirectionType {
        switch self {
        case .case(.updateAddress): return .updateAddress
        default: return .unknown
        }
    }
}

extension GraphQLEnum<OctopusGraphQL.TerminationFlowSurveyOptionSuggestionType> {
    var asTerminationSuggestionType: TerminationSuggestionType {
        switch self {
        case .case(.updateAddress): return .updateAddress
        case .case(.upgradeCoverage): return .upgradeCoverage
        case .case(.downgradePrice): return .downgradePrice
        case .case(.redirect): return .redirect
        case .case(.info): return .info
        case .case(.autoCancelSold): return .autoCancelSold
        case .case(.autoCancelScrapped): return .autoCancelScrapped
        case .case(.autoDecommission): return .autoDecommission
        case .case(.autoCancelDecommission): return .autoCancelDecommission
        case .case(.carAlreadyDecommission): return .carAlreadyDecommission
        default: return .unknown
        }
    }
}
