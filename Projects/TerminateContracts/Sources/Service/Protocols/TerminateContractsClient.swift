import Foundation
import hCore

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

    func getNotificaiton(
        contractId: String,
        date: Date
    ) async throws -> TerminationNotification?
}

public struct TerminateStepResponse: Equatable, Sendable {
    let context: String
    let step: TerminationContractStep
    let progress: Float?

    public init(context: String, step: TerminationContractStep, progress: Float?) {
        self.context = context
        self.step = step
        self.progress = progress
    }
}

public enum TerminationContractStep: Equatable, Sendable {
    case setTerminationDateStep(model: TerminationFlowDateNextStepModel)
    case setTerminationDeletion(model: TerminationFlowDeletionNextModel)
    case setSuccessStep(model: TerminationFlowSuccessNextModel)
    case setFailedStep(model: TerminationFlowFailedNextModel)
    case setTerminationSurveyStep(model: TerminationFlowSurveyStepModel)
    case openTerminationUpdateAppScreen
}

public enum TerminationError: Error {
    case missingContext
}

extension TerminationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingContext:
            return L10n.General.errorBody
        }
    }
}
