import Foundation
import TerminateContractsCore
import hCore

@testable import TerminateContractsUI

class MockTerminateContractsClient: TerminateContractsClient {
    var surveyDataToReturn: TerminationSurveyData = MockTerminationData.terminateSurveyData
    var terminateResultToReturn: TerminationContractResult = .success
    var deleteResultToReturn: TerminationContractResult = .success
    var notificationToReturn: TerminationNotification?
    var withdrawalDataToReturn = ContractWithdrawalData(
        statusText: "Active since today",
        action: .terminateWithDate(minDate: "2026-11-24", maxDate: "2026-11-24", extraCoverage: []),
        email: "member@hedvig.com"
    )
    var withdrawResultToReturn: TerminationContractResult = .success
    var errorToThrow: Error?
    var events = [Event]()

    enum Event: Equatable {
        case getTerminationSurvey(contractId: String)
        case terminateContract(contractId: String, terminationDate: String, surveyOptionId: String)
        case deleteContract(contractId: String, surveyOptionId: String)
        case getContractWithdrawal(contractId: String)
        case withdrawContract(contractId: String)
        case getNotification(contractId: String)
    }

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        events.append(.getTerminationSurvey(contractId: contractId))
        if let error = errorToThrow { throw error }
        return surveyDataToReturn
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        events.append(
            .terminateContract(contractId: contractId, terminationDate: terminationDate, surveyOptionId: surveyOptionId)
        )
        if let error = errorToThrow { throw error }
        return terminateResultToReturn
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        events.append(.deleteContract(contractId: contractId, surveyOptionId: surveyOptionId))
        if let error = errorToThrow { throw error }
        return deleteResultToReturn
    }

    func getContractWithdrawal(contractId: String) async throws -> ContractWithdrawalData {
        events.append(.getContractWithdrawal(contractId: contractId))
        if let error = errorToThrow { throw error }
        return withdrawalDataToReturn
    }

    func withdrawContract(contractId: String) async throws -> TerminationContractResult {
        events.append(.withdrawContract(contractId: contractId))
        if let error = errorToThrow { throw error }
        return withdrawResultToReturn
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        events.append(.getNotification(contractId: contractId))
        if let error = errorToThrow { throw error }
        return notificationToReturn
    }
}

enum MockTerminationData {
    static let basicOptions: [TerminationSurveyOption] = [
        .init(id: "opt1", title: "Better price", feedbackRequired: false, suggestion: nil, subOptions: []),
        .init(id: "opt2", title: "Moving abroad", feedbackRequired: true, suggestion: nil, subOptions: []),
    ]

    static let terminateSurveyData = TerminationSurveyData(
        options: basicOptions,
        action: .terminateWithDate(
            minDate: "2026-04-01",
            maxDate: "2026-07-01",
            extraCoverage: [.init(displayName: "Travel plus", displayValue: "49 kr/mo")]
        )
    )

    static let deleteSurveyData = TerminationSurveyData(
        options: basicOptions,
        action: .deleteInsurance(
            extraCoverage: [.init(displayName: "Accident coverage", displayValue: "29 kr/mo")]
        )
    )

    static let testConfig = TerminationConfirmConfig(
        contractId: "contract-123",
        contractDisplayName: "Home Insurance",
        contractExposureName: "Kungsgatan 1",
        activeFrom: "2025-01-01",
        typeOfContract: .seApartmentBrf
    )

    static let withdrawalConfig = TerminationConfirmConfig(
        contractId: "contract-123",
        contractDisplayName: "Home Insurance",
        contractExposureName: "Kungsgatan 1",
        activeFrom: "2026-11-20",
        typeOfContract: .seApartmentBrf,
        supportsWithdrawal: true
    )

    static let fixedDateWithdrawal = ContractWithdrawalData(
        statusText: "Your insurance is active since 20 Nov",
        action: .terminateWithDate(minDate: "2026-11-20", maxDate: "2026-11-20", extraCoverage: []),
        email: "member@hedvig.com"
    )

    static let dateRangeWithdrawal = ContractWithdrawalData(
        statusText: "Your insurance starts on 1 Dec",
        action: .terminateWithDate(minDate: "2026-11-24", maxDate: "2026-12-01", extraCoverage: []),
        email: "member@hedvig.com"
    )

    static let deletionWithdrawal = ContractWithdrawalData(
        statusText: "Your insurance has not started yet",
        action: .deleteInsurance(extraCoverage: []),
        email: "member@hedvig.com"
    )
}
