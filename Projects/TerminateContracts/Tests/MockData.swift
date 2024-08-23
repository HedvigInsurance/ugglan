import Foundation
import hCore

@testable import TerminateContracts

struct MockData {
    @discardableResult
    static func createMockTerminateContractsService(
        start: @escaping StartTermination = { contractId in
            .init(
                context: "context",
                action: .startTermination(
                    config: .init(
                        contractId: contractId,
                        contractDisplayName: "contract display name",
                        contractExposureName: "contract exposure name",
                        activeFrom: nil
                    )
                )
            )
        },
        sendDate: @escaping SendTerminationDate = { inputDateToString, context in
            .init(
                context: context,
                action: .setTerminationDate(terminationDate: inputDateToString.localDateToDate ?? Date())
            )
        },
        confirmDelete: @escaping SendConfirmDelete = { context in
            .init(
                context: context,
                action: .sendConfirmDelete
            )
        },
        surveySend: @escaping SendSurvey = { context, option, inputData in
            .init(
                context: context,
                action: .submitSurvey(
                    option: option,
                    feedback: inputData
                )
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
typealias SendConfirmDelete = (String) async throws -> TerminateStepResponse
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

    func sendConfirmDelete(terminationContext: String) async throws -> TerminateStepResponse {
        events.append(.sendConfirmDelete)
        let data = try await confirmDelete(terminationContext)
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
