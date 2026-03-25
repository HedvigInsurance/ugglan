import Foundation
import hCore

@testable import EditStakeholders

@MainActor
struct MockData {
    @discardableResult
    static func createMockEditStakeholdersService(
        commitMidtermChange: @escaping CommitMidtermChange = { _ in
        },
        fetchPersonalInformation: @escaping FetchPersonalInformation = { _ in
            .init(firstName: "first name", lastName: "last name")
        },
        submitIntent: @escaping CreateIntent = { _, _, _ in
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
    ) -> MockEditStakeholdersService {
        let service = MockEditStakeholdersService(
            commitMidtermChange: commitMidtermChange,
            fetchPersonalInformation: fetchPersonalInformation,
            submitIntent: submitIntent,
            fetchContracts: fetchContracts
        )
        Dependencies.shared.add(module: Module { () -> EditStakeholdersClient in service })
        return service
    }
}

typealias CommitMidtermChange = (String) async throws -> Void
typealias FetchPersonalInformation = (String) async throws -> PersonalData?
typealias CreateIntent = @Sendable (String, [Stakeholder], StakeholderType) async throws -> Intent
typealias FetchContracts = () async throws -> [Contract]

class MockEditStakeholdersService: EditStakeholdersClient {
    var events = [Event]()

    var commitMidtermChange: CommitMidtermChange
    var fetchPersonalInformation: FetchPersonalInformation
    var submitIntent: CreateIntent
    var fetchContracts: FetchContracts

    enum Event {
        case commitMidtermChange
        case fetchPersonalInformation
        case createIntent
        case fetchContracts
    }

    init(
        commitMidtermChange: @escaping CommitMidtermChange,
        fetchPersonalInformation: @escaping FetchPersonalInformation,
        submitIntent: @escaping CreateIntent,
        fetchContracts: @escaping FetchContracts
    ) {
        self.commitMidtermChange = commitMidtermChange
        self.fetchPersonalInformation = fetchPersonalInformation
        self.submitIntent = submitIntent
        self.fetchContracts = fetchContracts
    }

    func fetchContracts() async throws -> [Contract] {
        events.append(.fetchContracts)
        return try await fetchContracts()
    }

    func commitMidtermChange(commitId: String) async throws {
        events.append(.commitMidtermChange)
        try await commitMidtermChange(commitId)
    }

    func fetchPersonalInformation(SSN: String) async throws -> PersonalData? {
        events.append(.fetchPersonalInformation)
        let data = try await fetchPersonalInformation(SSN)
        return data
    }

    func createIntent(
        contractId: String,
        stakeholders: [Stakeholder],
        type: StakeholderType
    ) async throws -> Intent {
        events.append(.createIntent)
        let data = try await submitIntent(contractId, stakeholders, type)
        return data
    }
}
