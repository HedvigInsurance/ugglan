import Foundation
import TerminateContractsCore
import hCore

@testable import TerminateContractsUI

/// Stub that answers immediately and never throws; the view model tests only vary the notification.
class MockTerminateContractsClient: TerminateContractsClient {
    var notificationToReturn: TerminationNotification?

    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        MockTerminationData.terminateSurveyData
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        .success
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        .success
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        notificationToReturn
    }
}

enum MockTerminationData {
    static let terminateSurveyData = TerminationSurveyData(
        options: [],
        action: .terminateWithDate(
            minDate: "2026-04-01",
            maxDate: "2026-07-01",
            extraCoverage: [.init(displayName: "Travel plus", displayValue: "49 kr/mo")]
        )
    )

    static let deleteSurveyData = TerminationSurveyData(options: [], action: .deleteInsurance(extraCoverage: []))

    static let testConfig = TerminationConfirmConfig(
        contractId: "contract-123",
        contractDisplayName: "Home Insurance",
        contractExposureName: "Kungsgatan 1",
        activeFrom: "2025-01-01",
        typeOfContract: .seApartmentBrf
    )
}
