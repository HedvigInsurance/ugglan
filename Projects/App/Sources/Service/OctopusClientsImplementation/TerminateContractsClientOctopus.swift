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
        let query = OctopusGraphQL.TerminationSurveyQuery(contractId: contractId)
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
        let query = OctopusGraphQL.TerminationFlowNotificationQuery(input: input)
        let data = try await octopus.client.fetch(query: query)
        guard let notification = data.currentMember.terminationFlowNotification else { return nil }
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
        let fragment = option.fragments.terminationSurveyOptionFragment
        return .init(
            id: fragment.id,
            title: fragment.title,
            feedbackRequired: fragment.feedbackRequired,
            suggestion: fragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment.asSuggestion,
            subOptions: option.subOptions.map { subOption in
                let subFragment = subOption.fragments.terminationSurveyOptionFragment
                return .init(
                    id: subFragment.id,
                    title: subFragment.title,
                    feedbackRequired: subFragment.feedbackRequired,
                    suggestion: subFragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment
                        .asSuggestion,
                    subOptions: subOption.subOptions.map { subSubOption in
                        let subSubFragment = subSubOption.fragments.terminationSurveyOptionFragment
                        return .init(
                            id: subSubFragment.id,
                            title: subSubFragment.title,
                            feedbackRequired: subSubFragment.feedbackRequired,
                            suggestion: subSubFragment.suggestion?.fragments.terminationSurveyOptionSuggestionFragment
                                .asSuggestion,
                            subOptions: subSubOption.subOptions.map { leaf in
                                let leafFragment = leaf.fragments.terminationSurveyOptionFragment
                                return .init(
                                    id: leafFragment.id,
                                    title: leafFragment.title,
                                    feedbackRequired: leafFragment.feedbackRequired,
                                    suggestion: leafFragment.suggestion?.fragments
                                        .terminationSurveyOptionSuggestionFragment.asSuggestion,
                                    subOptions: []
                                )
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
            url: url
        )
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
