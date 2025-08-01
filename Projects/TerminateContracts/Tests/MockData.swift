import Foundation
import hCore

@testable import TerminateContracts

@MainActor
struct MockData {
    @discardableResult
    static func createMockTerminateContractsService(
        start: @escaping StartTermination = { _ in
            .init(
                context: "context",
                step: .setSuccessStep(model: .init(terminationDate: nil)),
                progress: 0
            )
        },
        sendDate: @escaping SendTerminationDate = { _, context in
            .init(
                context: context,
                step: .setTerminationDateStep(
                    model: .init(
                        id: "id",
                        maxDate: "2025-11-11",
                        minDate: Date().localDateString,
                        extraCoverageItem: [
                            .init(displayName: "Travel plus", displayValue: "45 days")
                        ],
                        notification: nil
                    )
                ),
                progress: 0
            )
        },
        confirmDelete: @escaping SendConfirmDelete = { context, model in
            .init(
                context: context,
                step: .setTerminationDeletion(
                    model: model
                        ?? .init(
                            id: "id",
                            extraCoverageItem: [
                                .init(displayName: "Travel plus", displayValue: "45 days")
                            ]
                        )
                ),
                progress: 0
            )
        },
        surveySend: @escaping SendSurvey = { context, _, _ in
            .init(
                context: context,
                step: .setTerminationSurveyStep(model: .init(id: "id", options: [], subTitleType: .generic)),
                progress: 0
            )
        }
    ) -> MockTerminateContractsService {
        let service = MockTerminateContractsService(
            start: start,
            sendDate: sendDate,
            confirmDelete: confirmDelete,
            surveySend: surveySend
        )
        Dependencies.shared.add(module: Module { () -> TerminateContractsClient in service })
        return service
    }
}

enum TerminationError: Error {
    case error
}

typealias StartTermination = (String) async throws -> TerminateStepResponse
typealias SendTerminationDate = (String, String) async throws -> TerminateStepResponse
typealias SendConfirmDelete = (String, TerminationFlowDeletionNextModel?) async throws -> TerminateStepResponse
typealias SendSurvey = (String, String, String?) async throws -> TerminateStepResponse

class MockTerminateContractsService: TerminateContractsClient {
    var events = [Event]()

    var start: StartTermination
    var sendDate: SendTerminationDate
    var confirmDelete: SendConfirmDelete
    var surveySend: SendSurvey

    enum Event {
        case startTermination
        case sendTerminationDate
        case sendConfirmDelete
        case sendSurvey
    }

    init(
        start: @escaping StartTermination,
        sendDate: @escaping SendTerminationDate,
        confirmDelete: @escaping SendConfirmDelete,
        surveySend: @escaping SendSurvey
    ) {
        self.start = start
        self.sendDate = sendDate
        self.confirmDelete = confirmDelete
        self.surveySend = surveySend
    }

    func startTermination(contractId: String) async throws -> TerminateStepResponse {
        events.append(.startTermination)
        let data = try await start(contractId)
        return data
    }

    func sendTerminationDate(
        inputDateToString: String,
        terminationContext: String
    ) async throws -> TerminateStepResponse {
        events.append(.sendTerminationDate)
        let data = try await sendDate(inputDateToString, terminationContext)
        return data
    }

    func sendConfirmDelete(
        terminationContext: String,
        model: TerminationFlowDeletionNextModel?
    ) async throws -> TerminateStepResponse {
        events.append(.sendConfirmDelete)
        let data = try await confirmDelete(terminationContext, model)
        return data
    }

    func sendSurvey(
        terminationContext: String,
        option: String,
        inputData: String?
    ) async throws -> TerminateStepResponse {
        events.append(.sendSurvey)
        let data = try await surveySend(terminationContext, option, inputData)
        return data
    }
}
