import Foundation
import hCore

@MainActor
class TerminateContractsService {
    @Inject private var client: TerminateContractsClient
    func startTermination(contractId: String) async throws -> TerminateStepResponse {
        try await client.startTermination(contractId: contractId)
    }

    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        log.info(
            "TerminateContractsService: sendTerminationDate date: \(inputDateToString) with context: \(terminationContext)"
        )
        let response = try await client.sendTerminationDate(
            inputDateToString: inputDateToString,
            terminationContext: terminationContext
        )
        log.info("TerminateContractsService: success with context: \(response.context)")
        return response
    }

    func sendConfirmDelete(
        terminationContext: String,
        model: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse {
        log.info("TerminateContractsService: sendConfirmDelete with context: \(terminationContext)")
        let response = try await client.sendConfirmDelete(terminationContext: terminationContext, model: model)
        log.info("TerminateContractsService: sendConfirmDelete success with context: \(response.context)")
        return response
    }

    func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        log.info(
            "TerminateContractsService: sendConfirmDelete with context: \(terminationContext) and option: \(option) and inputData: \(inputData ?? "")"
        )
        let response = try await client.sendSurvey(
            terminationContext: terminationContext,
            option: option,
            inputData: inputData
        )
        log.info("TerminateContractsService: sendConfirmDelete success context: \(response.context)")
        return response
    }
}
