import Foundation
import hCore

@testable import Home

@MainActor
struct MockData {
    @discardableResult
    static func createMockHomeService(
        fetchImportantMessages: @escaping FetchImportantMessages = {
            []
        },
        fetchMemberState: @escaping FetchMemberState = {
            .init(
                id: "id",
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
        },
        fetchFAQ: @escaping FetchFAQ = {
            .init(topics: [], commonQuestions: [])
        }
    ) -> MockHomeService {
        let service = MockHomeService(
            fetchImportantMessages: fetchImportantMessages,
            fetchMemberState: fetchMemberState,
            fetchQuickActions: fetchQuickActions,
            fetchLatestMessageState: fetchLatestMessageState,
            fetchFAQ: fetchFAQ
        )
        Dependencies.shared.add(module: Module { () -> HomeClient in service })
        return service
    }
}

typealias FetchImportantMessages = () async throws -> [ImportantMessage]
typealias FetchMemberState = () async throws -> MemberState
typealias FetchQuickActions = () async throws -> [QuickAction]
typealias FetchLatestMessageState = @Sendable () async throws -> Home.MessageState
typealias FetchFAQ = () async throws -> Home.HelpCenterFAQModel

class MockHomeService: HomeClient {
    var events = [Event]()
    var fetchImportantMessages: FetchImportantMessages
    var fetchMemberState: FetchMemberState
    var fetchQuickActions: FetchQuickActions
    var fetchLatestMessageState: FetchLatestMessageState
    var fetchFAQ: FetchFAQ
    enum Event {
        case getImportantMessages
        case getMemberState
        case getQuickActions
        case getMessagesState
        case getFaq
    }

    init(
        fetchImportantMessages: @escaping FetchImportantMessages,
        fetchMemberState: @escaping FetchMemberState,
        fetchQuickActions: @escaping FetchQuickActions,
        fetchLatestMessageState: @escaping FetchLatestMessageState,
        fetchFAQ: @escaping FetchFAQ
    ) {
        self.fetchImportantMessages = fetchImportantMessages
        self.fetchMemberState = fetchMemberState
        self.fetchQuickActions = fetchQuickActions
        self.fetchLatestMessageState = fetchLatestMessageState
        self.fetchFAQ = fetchFAQ
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

    func getFAQ() async throws -> Home.HelpCenterFAQModel {
        events.append(.getFaq)
        let data = try await fetchFAQ()
        return data
    }
}
