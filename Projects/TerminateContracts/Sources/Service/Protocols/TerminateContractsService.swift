import Flow

public protocol TerminateContractsService {
    func startTermination(contractId: String) async throws -> TeminateStepResponse
    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TeminateStepResponse
    func sendConfirmDelete(terminationContext: String) async throws -> TeminateStepResponse
}

public struct TeminateStepResponse {
    let context: String
    let action: TerminationContractAction
}
