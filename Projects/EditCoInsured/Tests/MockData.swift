import Foundation
import hCore

@testable import EditCoInsured
@testable import EditCoInsuredShared

struct MockData {
    @discardableResult
    static func createMockEditCoInsuredService(
        sendMidtermChangeIntent: @escaping SendMidtermChangeIntent = { commitId in

        },
        fetchPersonalInformation: @escaping FetchPersonalInformation = { SSN in
            .init(firstName: "first name", lastName: "last name")
        },
        submitIntent: @escaping SendIntent = { contractId, coInsured in
            .init(
                activationDate: Date().localDateString,
                currentPremium: .init(amount: "239", currency: "SEK"),
                newPremium: .init(amount: "269", currency: "SEK"),
                id: "id",
                state: "state"
            )
        }
    ) -> MockEditCoInsuredService {
        let service = MockEditCoInsuredService(
            sendMidtermChangeIntent: sendMidtermChangeIntent,
            fetchPersonalInformation: fetchPersonalInformation,
            submitIntent: submitIntent
        )
        Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in service })
        return service
    }
}

typealias SendMidtermChangeIntent = (String) async throws -> Void
typealias FetchPersonalInformation = (String) async throws -> PersonalData?
typealias SendIntent = (String, [EditCoInsuredShared.CoInsuredModel]) async throws -> Intent

class MockEditCoInsuredService: EditCoInsuredClient {
    var events = [Event]()

    var sendMidtermChangeIntent: SendMidtermChangeIntent
    var fetchPersonalInformation: FetchPersonalInformation
    var submitIntent: SendIntent

    enum Event {
        case sendMidtermChangeIntentCommit
        case getPersonalInformation
        case sendIntent
    }

    init(
        sendMidtermChangeIntent: @escaping SendMidtermChangeIntent,
        fetchPersonalInformation: @escaping FetchPersonalInformation,
        submitIntent: @escaping SendIntent
    ) {
        self.sendMidtermChangeIntent = sendMidtermChangeIntent
        self.fetchPersonalInformation = fetchPersonalInformation
        self.submitIntent = submitIntent
    }

    func sendMidtermChangeIntentCommit(commitId: String) async throws {
        events.append(.sendMidtermChangeIntentCommit)
        try await sendMidtermChangeIntent(commitId)
    }

    func getPersonalInformation(SSN: String) async throws -> PersonalData? {
        events.append(.getPersonalInformation)
        let data = try await fetchPersonalInformation(SSN)
        return data
    }

    func sendIntent(contractId: String, coInsured: [EditCoInsuredShared.CoInsuredModel]) async throws -> Intent {
        events.append(.sendIntent)
        let data = try await submitIntent(contractId, coInsured)
        return data
    }
}
