import hCore

public class TerminateContractsClientDemo: TerminateContractsClient {
    public func startTermination(contractId _: String) async throws -> TerminateStepResponse {
        .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendTerminationDate(
        inputDateToString _: String,
        terminationContext _: String
    ) async throws -> TerminateStepResponse {
        .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendConfirmDelete(
        terminationContext _: String,
        model _: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse {
        .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }

    public func sendSurvey(
        terminationContext _: String,
        option _: String,
        inputData _: String?
    ) async throws -> TerminateStepResponse {
        .init(context: "", step: .setSuccessStep(model: .init(terminationDate: nil)), progress: 0)
    }
}
