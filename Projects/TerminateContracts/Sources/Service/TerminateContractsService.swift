import AutomaticLog
import Foundation
import hCore

@MainActor
class TerminateContractsService {
    @Inject private var client: TerminateContractsClient

    @Log([.error])
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        try await client.getTerminationSurvey(contractId: contractId)
    }

    @Log([.error])
    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        nonisolated(unsafe) let client = client
        async let result = try await client.terminateContract(
            contractId: contractId,
            terminationDate: terminationDate,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        async let delayTask: () = delay(3)
        let (data, _) = try await (result, delayTask)
        return data
    }

    @Log([.error])
    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        nonisolated(unsafe) let client = client
        async let result = try await client.deleteContract(
            contractId: contractId,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        async let delayTask: () = delay(3)
        let (data, _) = try await (result, delayTask)
        return data
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        try await client.getNotification(contractId: contractId, date: date)
    }
}
