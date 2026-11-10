import AutomaticLog
import Foundation
import hCore

@MainActor
public class TerminateContractsService {
    @Inject private var client: TerminateContractsClient

    public init() {}

    @Log()
    public func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        try await client.getTerminationSurvey(contractId: contractId)
    }

    @Log(masked: ["comment"])
    public func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.withMinimumDuration(.seconds(3)) {
            try await client.terminateContract(
                contractId: contractId,
                terminationDate: terminationDate,
                surveyOptionId: surveyOptionId,
                comment: comment
            )
        }
    }

    @Log(masked: ["comment"])
    public func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.withMinimumDuration(.seconds(3)) {
            try await client.deleteContract(
                contractId: contractId,
                surveyOptionId: surveyOptionId,
                comment: comment
            )
        }
    }

    public func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        try await client.getNotification(contractId: contractId, date: date)
    }
}
