import Foundation
import hCore

@testable import TerminateContractsCore

class MockTerminateContractsClient: TerminateContractsClient {
    var surveyDataToReturn: TerminationSurveyData?
    var terminateResultToReturn: TerminationContractResult = .success
    var deleteResultToReturn: TerminationContractResult = .success
    var notificationToReturn: TerminationNotification?
    var errorToThrow: Error?

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        if let error = errorToThrow { throw error }
        return surveyDataToReturn!
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        if let error = errorToThrow { throw error }
        return terminateResultToReturn
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        if let error = errorToThrow { throw error }
        return deleteResultToReturn
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        if let error = errorToThrow { throw error }
        return notificationToReturn
    }
}

enum MockTerminationData {
    static let terminateWithDateAction: TerminationAction = .terminateWithDate(
        minDate: "2026-04-01",
        maxDate: "2026-07-01",
        extraCoverage: [.init(displayName: "Travel plus", displayValue: "49 kr/mo")]
    )

    static let basicOptions: [TerminationSurveyOption] = [
        .init(id: "opt1", title: "Better price", feedbackRequired: false, suggestion: nil, subOptions: []),
        .init(id: "opt2", title: "Moving abroad", feedbackRequired: true, suggestion: nil, subOptions: []),
    ]

    static let terminateSurveyData = TerminationSurveyData(
        options: basicOptions,
        action: terminateWithDateAction
    )
}
