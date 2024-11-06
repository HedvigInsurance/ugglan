import hCore

public class TerminateContractsClientDemo: TerminateContractsClient {
    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen), progress: 0)
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen), progress: 0)
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen), progress: 0)
    }

    public func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationFailScreen), progress: 0)
    }
}
