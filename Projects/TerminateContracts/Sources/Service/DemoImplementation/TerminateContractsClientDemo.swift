import hCore

public class TerminateContractsClientDemo: TerminateContractsClient {
    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen))
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen))
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .navigationAction(action: .openTerminationSuccessScreen))
    }
}
