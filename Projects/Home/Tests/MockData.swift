import Foundation
import hCore

@testable import Home

struct MockData {
    @discardableResult
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
        fetchLatestMessageState: @escaping FetchLatestMessageState = {
            .init(hasNewMessages: false, hasSentOrRecievedAtLeastOneMessage: false, lastMessageTimeStamp: nil)
        }
    ) -> MockHomeService {
        let service = MockHomeService(
            fetchImportantMessages: fetchImportantMessages,
            fetchMemberState: fetchMemberState,
            fetchQuickActions: fetchQuickActions,
            fetchLatestMessageState: fetchLatestMessageState
        )
        Dependencies.shared.add(module: Module { () -> HomeClient in service })
        return service
    }
}

typealias FetchImportantMessages = () async throws -> [ImportantMessage]
typealias FetchMemberState = () async throws -> MemberState
typealias FetchQuickActions = () async throws -> [QuickAction]
typealias FetchLatestMessageState = () async throws -> Home.MessageState

class MockHomeService: HomeClient {
    var events = [Event]()
    var fetchImportantMessages: FetchImportantMessages
    var fetchMemberState: FetchMemberState
    var fetchQuickActions: FetchQuickActions
    var fetchLatestMessageState: FetchLatestMessageState

    enum Event {
        case getImportantMessages
        case getMemberState
        case getQuickActions
        case getMessagesState
    }

    init(
        fetchImportantMessages: @escaping FetchImportantMessages,
        fetchMemberState: @escaping FetchMemberState,
        fetchQuickActions: @escaping FetchQuickActions,
        fetchLatestMessageState: @escaping FetchLatestMessageState
    ) {
        self.fetchImportantMessages = fetchImportantMessages
        self.fetchMemberState = fetchMemberState
        self.fetchQuickActions = fetchQuickActions
        self.fetchLatestMessageState = fetchLatestMessageState
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

    func getMessagesState() async throws -> Home.MessageState {
        events.append(.getMessagesState)
        let data = try await fetchLatestMessageState()
        return data
    }
}
