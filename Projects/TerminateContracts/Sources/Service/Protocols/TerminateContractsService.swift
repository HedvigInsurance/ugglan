public protocol TerminateContractsService {
    func startTermination(contractId: String) async throws -> TerminateStepResponse
    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse
    func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse
}

public struct TerminateStepResponse {
    let context: String
    let action: TerminationContractAction
}
