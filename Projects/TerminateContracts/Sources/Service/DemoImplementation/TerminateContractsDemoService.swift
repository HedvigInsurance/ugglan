import hCore

public class TerminateContractsDemoService: TerminateContractsService {
    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow)
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow)
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow)
    }
}
