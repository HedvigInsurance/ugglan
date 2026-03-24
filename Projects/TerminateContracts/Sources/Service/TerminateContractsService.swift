import Foundation
import hCore

@MainActor
class TerminateContractsService {
    @Inject private var client: TerminateContractsClient

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        log.info("TerminateContractsService: getTerminationSurvey for contractId: \(contractId)")
        let data = try await client.getTerminationSurvey(contractId: contractId)
        log.info("TerminateContractsService: getTerminationSurvey success")
        return data
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        log.info("TerminateContractsService: terminateContract for contractId: \(contractId) date: \(terminationDate)")
        let result = try await client.terminateContract(
            contractId: contractId,
            terminationDate: terminationDate,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        log.info("TerminateContractsService: terminateContract result: \(result)")
        return result
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        log.info("TerminateContractsService: deleteContract for contractId: \(contractId)")
        let result = try await client.deleteContract(
            contractId: contractId,
            surveyOptionId: surveyOptionId,
            comment: comment
        )
        log.info("TerminateContractsService: deleteContract result: \(result)")
        return result
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        log.info("TerminateContractsService: getNotification for contractId: \(contractId)")
        let data = try await client.getNotification(contractId: contractId, date: date)
        log.info("TerminateContractsService: getNotification success: \(data?.message ?? "nil")")
        return data
    }
}
