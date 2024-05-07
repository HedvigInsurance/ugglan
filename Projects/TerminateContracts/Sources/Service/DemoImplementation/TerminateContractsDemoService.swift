import hCore

public class TerminateContractsDemoService: TerminateContractsService {
    public func startTermination(contractId: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow(afterCancellationFinished: false))
    }

    public func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow(afterCancellationFinished: false))
    }

    public func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow(afterCancellationFinished: false))
    }

    public func sendSurvey(option: String, inputData: String?) async throws -> TerminateStepResponse {
        return .init(context: "", action: .dismissTerminationFlow(afterCancellationFinished: false))
    }
}
