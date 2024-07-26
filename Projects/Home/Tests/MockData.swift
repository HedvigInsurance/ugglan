import Foundation
import hCore

@testable import Home

struct MockData {
    static func createMockHomeService(
        fetchImportantMessages: @escaping FetchImportantMessages = {
            []
        },
        fetchMemberState: @escaping FetchMemberState = {
            .init(
                contracts: [],
                contractState: .active,
                futureState: .none
            )
        },
        fetchQuickActions: @escaping FetchQuickActions = {
            [
                .editCoInsured,
                .connectPayments,
            ]
        },
        fetchLastMessagesDates: @escaping FetchLastMessagesDates = {
            [:]
        }
    ) -> MockHomeService {
        let service = MockHomeService(
            fetchImportantMessages: fetchImportantMessages,
            fetchMemberState: fetchMemberState,
            fetchQuickActions: fetchQuickActions,
            fetchLastMessagesDates: fetchLastMessagesDates
        )
        Dependencies.shared.add(module: Module { () -> HomeClient in service })
        return service
    }
}

typealias FetchImportantMessages = () async throws -> [ImportantMessage]
typealias FetchMemberState = () async throws -> MemberState
typealias FetchQuickActions = () async throws -> [QuickAction]
typealias FetchLastMessagesDates = () async throws -> [String: Date]

class MockHomeService: HomeClient {
    var events = [Event]()
    var fetchImportantMessages: FetchImportantMessages
    var fetchMemberState: FetchMemberState
    var fetchQuickActions: FetchQuickActions
    var fetchLastMessagesDates: FetchLastMessagesDates

    enum Event {
        case getImportantMessages
        case getMemberState
        case getQuickActions
        case getLastMessagesDates
    }

    init(
        fetchImportantMessages: @escaping FetchImportantMessages,
        fetchMemberState: @escaping FetchMemberState,
        fetchQuickActions: @escaping FetchQuickActions,
        fetchLastMessagesDates: @escaping FetchLastMessagesDates
    ) {
        self.fetchImportantMessages = fetchImportantMessages
        self.fetchMemberState = fetchMemberState
        self.fetchQuickActions = fetchQuickActions
        self.fetchLastMessagesDates = fetchLastMessagesDates
    }

    func getImportantMessages() async throws -> [ImportantMessage] {
        events.append(.getImportantMessages)
        let data = try await fetchImportantMessages()
        return data
    }

    func getMemberState() async throws -> MemberState {
        events.append(.getMemberState)
        let data = try await fetchMemberState()
        return data
    }

    func getQuickActions() async throws -> [QuickAction] {
        events.append(.getQuickActions)
        let data = try await fetchQuickActions()
        return data
    }

    func getLastMessagesDates() async throws -> [String: Date] {
        events.append(.getLastMessagesDates)
        let data = try await fetchLastMessagesDates()
        return data
    }
}
