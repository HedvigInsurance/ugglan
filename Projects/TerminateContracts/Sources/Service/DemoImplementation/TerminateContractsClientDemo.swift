import Foundation
import hCore

class TerminateContractsClientDemo: TerminateContractsClient {
    func getTerminationSurvey(contractId: String) async throws -> TerminationSurveyData {
        try await Task.sleep(nanoseconds: 500_000_000)
        return TerminationSurveyData(
            options: [
                .init(
                    id: "option1",
                    title: "I found a better price",
                    feedbackRequired: false,
                    suggestion: .init(type: .downgradePrice, description: "We can offer you a better price", url: nil),
                    subOptions: []
                ),
                .init(
                    id: "option2",
                    title: "I'm moving abroad",
                    feedbackRequired: false,
                    suggestion: nil,
                    subOptions: [
                        .init(
                            id: "subOption1",
                            title: "I'm moving to another EU country",
                            feedbackRequired: true,
                            suggestion: nil,
                            subOptions: []
                        ),
                        .init(
                            id: "subOption2",
                            title: "I'm moving outside the EU",
                            feedbackRequired: false,
                            suggestion: nil,
                            subOptions: []
                        ),
                    ]
                ),
                .init(
                    id: "option3",
                    title: "Other reason",
                    feedbackRequired: true,
                    suggestion: nil,
                    subOptions: []
                ),
            ],
            action: .terminateWithDate(
                minDate: Date().localDateString,
                maxDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())?.localDateString ?? "",
                extraCoverage: [
                    .init(displayName: "Travel insurance", displayValue: "49 kr/month")
                ]
            )
        )
    }

    func terminateContract(
        contractId: String,
        terminationDate: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return .success
    }

    func deleteContract(
        contractId: String,
        surveyOptionId: String,
        comment: String?
    ) async throws -> TerminationContractResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return .success
    }

    func getNotification(contractId: String, date: Date) async throws -> TerminationNotification? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return .init(message: "Your insurance will be terminated on this date.", type: .info)
    }
}
