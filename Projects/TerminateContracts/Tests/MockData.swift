import Foundation

typealias StartTermination = (String) async throws -> TerminateStepResponse
typealias SendTerminationDate = (String, String) async throws -> TerminateStepResponse
typealias SendConfirmDelete = (String) async throws -> TerminateStepResponse
typealias SendSurvey = (String, String, String?) async throws -> TerminateStepResponse

class MockTerminateContractsService: TerminateContractsClient {
    var events = [Event]()

    var start: StartTermination
    var sendDate: SendTerminationDate
    var confirmDelete: SendConfirmDelete
    var survey: SendSurvey

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
        survey: @escaping SendSurvey

    ) {
        self.start = start
        self.sendDate = sendDate
        self.confirmDelete = confirmDelete
        self.survey = survey
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
        let data = try await survey(terminationContext, option, inputData)
        return data
    }
}
