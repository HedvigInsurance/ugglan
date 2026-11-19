import Foundation
import hCore

@MainActor
public protocol TerminateContractsClient {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData
    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult
    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult
    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification?
}
