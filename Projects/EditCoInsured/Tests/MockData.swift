import Foundation
import hCore

@testable import EditCoInsured

@MainActor
struct MockData {
    @discardableResult
    static func createMockEditCoInsuredService(
        sendMidtermChangeIntent: @escaping SendMidtermChangeIntent = { _ in
        },
        fetchPersonalInformation: @escaping FetchPersonalInformation = { _ in
            .init(firstName: "first name", lastName: "last name")
        },
        submitIntent: @escaping SendIntent = { _, _ in
            .init(
                activationDate: Date().localDateString,
                currentTotalCost: .init(gross: .sek(300), net: .sek(200)),
                newTotalCost: .init(gross: .sek(299), net: .sek(199)),
                id: "id",
                newCostBreakdown: []
            )
        },
        fetchContracts: @escaping FetchContracts = {
            []
        }
    ) -> MockEditCoInsuredService {
        let service = MockEditCoInsuredService(
            sendMidtermChangeIntent: sendMidtermChangeIntent,
            fetchPersonalInformation: fetchPersonalInformation,
            submitIntent: submitIntent,
            fetchContracts: fetchContracts
        )
        Dependencies.shared.add(module: Module { () -> EditCoInsuredClient in service })
        return service
    }
}

typealias SendMidtermChangeIntent = (String) async throws -> Void
typealias FetchPersonalInformation = (String) async throws -> PersonalData?
typealias SendIntent = @Sendable (String, [CoInsuredModel]) async throws -> Intent
typealias FetchContracts = () async throws -> [Contract]

class MockEditCoInsuredService: EditCoInsuredClient {
    var events = [Event]()

    var sendMidtermChangeIntent: SendMidtermChangeIntent
    var fetchPersonalInformation: FetchPersonalInformation
    var submitIntent: SendIntent
    var fetchContracts: FetchContracts

    enum Event {
        case sendMidtermChangeIntentCommit
        case getPersonalInformation
        case sendIntent
        case fetchContracts
    }

    init(
        sendMidtermChangeIntent: @escaping SendMidtermChangeIntent,
        fetchPersonalInformation: @escaping FetchPersonalInformation,
        submitIntent: @escaping SendIntent,
        fetchContracts: @escaping FetchContracts
    ) {
        self.sendMidtermChangeIntent = sendMidtermChangeIntent
        self.fetchPersonalInformation = fetchPersonalInformation
        self.submitIntent = submitIntent
        self.fetchContracts = fetchContracts
    }

    func fetchContracts() async throws -> [Contract] {
        events.append(.fetchContracts)
        return try await fetchContracts()
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

    func sendIntent(contractId: String, coInsured: [CoInsuredModel]) async throws -> Intent {
        events.append(.sendIntent)
        let data = try await submitIntent(contractId, coInsured)
        return data
    }
}
