import Foundation
import hCore

public class TerminateContractsClientDemo: TerminateContractsClient {
    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        return .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        return .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendConfirmDelete(
        terminationContext: String,
        model: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse {
        return .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        return .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func getNotificaiton(contractId: String, date: Date) async throws -> TerminationNotification? {
        return nil
    }

}
