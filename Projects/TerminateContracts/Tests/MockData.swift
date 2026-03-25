import Foundation
import hCore

@testable import TerminateContracts

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

    static let deleteAction: TerminationAction = .deleteInsurance(
        extraCoverage: [.init(displayName: "Accident coverage", displayValue: "29 kr/mo")]
    )

    static let basicOptions: [TerminationSurveyOption] = [
        .init(id: "opt1", title: "Better price", feedbackRequired: false, suggestion: nil, subOptions: []),
        .init(id: "opt2", title: "Moving abroad", feedbackRequired: true, suggestion: nil, subOptions: []),
    ]

    static let optionWithSubOptions: TerminationSurveyOption = .init(
        id: "opt3",
        title: "Other",
        feedbackRequired: false,
        suggestion: nil,
        subOptions: [
            .init(id: "sub1", title: "Sub reason 1", feedbackRequired: false, suggestion: nil, subOptions: []),
            .init(id: "sub2", title: "Sub reason 2", feedbackRequired: true, suggestion: nil, subOptions: []),
        ]
    )

    static let optionWithDeflectSuggestion: TerminationSurveyOption = .init(
        id: "opt4",
        title: "Selling my car",
        feedbackRequired: false,
        suggestion: .init(type: .autoDecommission, description: "You can decommission your car", url: nil),
        subOptions: []
    )

    static let optionWithBlockingSuggestion: TerminationSurveyOption = .init(
        id: "opt5",
        title: "Found better price",
        feedbackRequired: false,
        suggestion: .init(type: .downgradePrice, description: "We can offer a lower price", url: nil),
        subOptions: []
    )

    static let terminateSurveyData = TerminationSurveyData(
        options: basicOptions,
        action: terminateWithDateAction
    )

    static let deleteSurveyData = TerminationSurveyData(
        options: basicOptions,
        action: deleteAction
    )

    static let testConfig = TerminationConfirmConfig(
        contractId: "contract-123",
        contractDisplayName: "Home Insurance",
        contractExposureName: "Kungsgatan 1",
        activeFrom: "2025-01-01",
        typeOfContract: .seApartmentBrf
    )

    static let autoCancelContent = DeflectScreenContent.from(suggestionType: .autoCancelSold)!
    static let autoDecomContent = DeflectScreenContent.from(suggestionType: .carDecommissionInfo)!
    static let recommissionContent = DeflectScreenContent.from(suggestionType: .carAlreadyDecommission)!
}
