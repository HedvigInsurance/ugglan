import Foundation

@MainActor
public protocol TerminateContractsClient {
    func startTermination(contractId: String) async throws -> TerminateStepResponse
    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse
    func sendConfirmDelete(
        terminationContext: String,
        model: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse
    func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse
}

public struct TerminateStepResponse: Equatable, Sendable {
    let context: String
    let step: TerminationContractStep
    let progress: Float?
}

public enum TerminationContractStep: Equatable, Sendable {
    case setTerminationDateStep(model: TerminationFlowDateNextStepModel)
    case setTerminationDeletion(model: TerminationFlowDeletionNextModel)
    case setSuccessStep(model: TerminationFlowSuccessNextModel)
    case setFailedStep(model: TerminationFlowFailedNextModel)
    case setTerminationSurveyStep(model: TerminationFlowSurveyStepModel)
    case openTerminationUpdateAppScreen
}
